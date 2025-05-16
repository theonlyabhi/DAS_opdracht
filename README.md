# DAS - Technische Opdracht

Link to project: https://dasdemo-test-app.azurewebsites.net/

Deze repo bevat een Python Flask webapplicatie die het bericht "Hello from Abhishek!" toont. De applicatie is gecontaineriseerd met Docker en uitgerold in Azure via Terraform. De infrastructuur bestaat uit een resource group, een Azure Container Registry (ACR) voor het opslaan van Docker images, een App Service Plan en een App Service die draait met een managed identity. Voor monitoring is Application Insights gebruikt en gevoelige gegevens zoals secrets worden veilig opgeslagen in een Azure Key Vault. De App Service haalt deze secrets op via Key Vault referenties in de app settings, waarbij de managed identity toegang heeft tot de Key Vault. Voor extra beveiliging draait de container als non root user, worden secrets niet hardcoded maar via app settings geinjecteerd, is HTTPS standaard ingeschakeld en worden uitsluitend images uit de eigen container registry gebruikt. Daarnaast is er een Azure Storage Account en een private container aangemaakt voor het opslaan van de Terraform state file. Omdat Terraform vereist dat de backend al bestaat voordat deze geconfigureerd kan worden, zijn de storage account en container eerst uitgerold. Vervolgens is de backend configuratie opgenomen in het terraform block zelf, zodat de state file automatisch wordt beheerd in Azure Storage.

## Gebruikte technologieen

- **Python/Flask** - Webapplicatie
- **Docker** - Containerisatie van de app
- **Terraform** - Infrastructure as Code 
- **Azure**:
    - Resource Group
    - Container Registry
    - App Service
    - App Service Plan
    - Application Insights
    - Role Assignment
    - Managed Identity Configuration
    - Key Vault
    - Storage Account

## Deploy stappen

1. **Terraform configuratie uitvoeren**

    Ga naar de terraform map en voer uit:
    ```bash
    # Terraform initialisatie
    terraform init
    terraform validate
    terraform workspace new test
    terraform plan
    terraform apply

    # Azure login
    az login
    az acr login --name dasdemotestacr

    # Docker build & push
    docker build -t dasdemotestacr.azurecr.io/abhi-hello:latest .
    docker push dasdemotestacr.azurecr.io/abhi-hello:latest
    ```
    
2. **Bezoek de applicatie**

    Na deployment kun je app service url openen in je browser.

## Veiligheid 

- Container draait als non-root user
- Secrets worden via app settings geinjecteerd
- HTTPS standaard ingeschakeld via Azure App Service
- Alleen images uit eigen registry worden gebruikt
- Managed Identity wordt gebruikt voor App Service om images te pullen uit Azure Container Registry (ACR)
- Tags zijn toegevoegd aan alle resources voor betere organisatie en beheer
- Gebruik gemaakt van Terraform workspaces voor meerdere omgevingen (dev, test, prod)
- De sleutels van Application Insights worden veilig opgeslagen in Azure Key Vault. De App Service haalt deze op via een managed identity en Key Vault referenties in de app settings
- De Terraform state file wordt opgeslagen in een beveiligde Azure Storage Account met een private container. Dit zorgt voor veilige opslag, versiebeheer en locking van de infrastructuurstatus.

### Monitoring en Troubleshooting

#### Application Insights
Application Insights is geïntegreerd met de App Service en biedt uitgebreide inzichten in de prestaties en het gedrag van de applicatie.

**Wat je kunt doen:**
- Live Metrics Stream
- Failures analyseren
- Performance per endpoint
- Logs zoeken met KQL

**Toegang:**
1. Ga naar de Azure Portal.
2. Navigeer naar de Application Insights resource.
3. Gebruik het menu aan de linkerkant.

#### App Service Logging
De App Service verzamelt container logs.

**Wat je kunt doen:**
- Live logs bekijken via Log Stream
- Diagnostische logs inschakelen

**Toegang:**
1. Ga naar de Azure Portal.
2. Navigeer naar de App Service.
3. Klik op Log stream.


## Structuur
```
-app\
    -main.py
-terraform\
    -main.tf
    -locals.tf
    -variables.tf
    -terraform.tfvars
-Dockerfile
-requirements.txt
-README.md
```
## Auteur

Abhishek Kaul Kumar