terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
  }

  backend "azurerm" {
    resource_group_name  = "dasdemo-test-rg"
    storage_account_name = "dasdemotestst"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azapi" {}

# Maakt een resource group aan waarin alle Azure resources worden geplaatst
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${terraform.workspace}-rg"
  location = var.location
  tags     = local.common_tags
}

# Maakt een storage account aan voor het opslaan van Terraform state bestanden
resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.prefix}${terraform.workspace}st"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

# Maakt een container aan binnen het storage account waarin de Terraform state file wordt opgeslagen
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Maakt een Azure Container Registry aan voor het opslaan van Docker images
# De App Service haalt hier de container image vandaan
# Authenticatie gebeurt via managed identity, dus admin access staat uit
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}${terraform.workspace}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.common_tags
}

# Maakt een Application Insights resource aan voor het monitoren van de applicatie
resource "azurerm_application_insights" "ai" {
  name                = "${var.prefix}-${terraform.workspace}-appi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = local.common_tags
}

# Maakt een App Service Plan aan waarop de App Service draait
resource "azurerm_app_service_plan" "plan" {
  name                = "${var.prefix}-${terraform.workspace}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  tags                = local.common_tags

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Maakt een App Service aan die een Docker container draait vanuit ACR
# De App Service krijgt een system-assigned managed identity voor veilige toegang tot ACR en Key Vault
resource "azurerm_app_service" "app" {
  name                = "${var.prefix}-${terraform.workspace}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  tags                = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_PORT                              = "80"
    APPINSIGHTS_INSTRUMENTATIONKEY             = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.kv.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.ai_key.name})"
    APPLICATIONINSIGHTS_CONNECTION_STRING      = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.kv.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.ai_connection_string.name})"
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
  }

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.image_name}:latest"
    always_on        = true
  }

  https_only = true
  depends_on = [azurerm_container_registry.acr]
}

# Geeft de App Service (via managed identity) rechten om images te pullen uit de Azure Container Registry
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.app.identity[0].principal_id

  depends_on = [azurerm_app_service.app]
}

# Schakelt het gebruik van managed identity in voor het ophalen van container images uit ACR
resource "azapi_update_resource" "app_service_acr" {
  type      = "Microsoft.Web/sites/config@2021-02-01"
  parent_id = azurerm_app_service.app.id
  name      = "web"
  body = jsonencode({
    properties = {
      acrUseManagedIdentityCreds = true
    }
  })

  depends_on = [azurerm_app_service.app]
}

# Haalt tenant info op voor toegang tot key vault
data "azurerm_client_config" "current" {}

# Maakt een Key Vault aan voor het veilig opslaan van gevoelige gegevens zoals secrets.
resource "azurerm_key_vault" "kv" {
  name                     = "${var.prefix}-${terraform.workspace}-kv"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
  tags                     = local.common_tags
}

# Geeft de gebruiker toegang tot de key vault om secrets aan te maken en op te vragen
resource "azurerm_key_vault_access_policy" "app_service_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "Set", "List"]
}

# Geeft de App Service via managed identity alleen leesrechten op secrets in de Key Vault
# zodat de app tijdens runtime secrets kan ophalen 
resource "azurerm_key_vault_access_policy" "app_service_identity" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_app_service.app.identity[0].principal_id

  secret_permissions = ["Get"]
}

# Maakt een secret aan in de Key Vault met de instrumentation key van Application Insight
# Wacht met aanmaken totdat Application Insight en de access policy voor Terraform klaar zijn
resource "azurerm_key_vault_secret" "ai_key" {
  name         = "AppInsightsInstrumentationKey"
  value        = azurerm_application_insights.ai.instrumentation_key
  key_vault_id = azurerm_key_vault.kv.id
}

# Maakt een secret aan in de Key Vault met de connection key van Application Insight
# Wacht met aanmaken totdat Application Insight en de access policy voor Terraform klaar zijn
resource "azurerm_key_vault_secret" "ai_connection_string" {
  name         = "AppInsightsConnectionString"
  value        = azurerm_application_insights.ai.connection_string
  key_vault_id = azurerm_key_vault.kv.id
}