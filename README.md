
# 🚀 DAS - Technische Opdracht

**Live demo:** https://dasdemo-test-app.azurewebsites.net

---

## 📌 Over dit project

Deze repo bevat een Python Flask webapplicatie. De applicatie is gecontaineriseerd met Docker en uitgerold in Azure via Terraform. De infrastructuur bestaat uit een resource group, een Azure Container Registry (ACR) voor het opslaan van Docker images, een App Service Plan en een App Service die draait met een managed identity. Voor monitoring is Application Insights gebruikt en gevoelige gegevens zoals secrets worden veilig opgeslagen in een Azure Key Vault. De App Service haalt deze secrets op via Key Vault referenties in de app settings, waarbij de managed identity toegang heeft tot de Key Vault. Voor extra beveiliging draait de container als non root user, worden secrets niet hardcoded maar via app settings geinjecteerd, is HTTPS standaard ingeschakeld en worden uitsluitend images uit de eigen container registry gebruikt. Daarnaast is er een Azure Storage Account en een private container aangemaakt voor het opslaan van de Terraform state file.

De applicatie toont een eenvoudige boodschap:

> “Hello from Abhishek!”

---

## 🧰 Tech Stack

- **Backend:** Python (Flask)
- **Containerisatie:** Docker
- **Infrastructure as Code:** Terraform
- **Cloud Platform:** Microsoft Azure (App Service, ACR, Key Vault, Application Insights, Storage Account)

---

## 🔐 Veiligheid

- 🔒 App draait als **non-root** gebruiker
- 🔒 **Secrets** worden opgehaald via **Key Vault referenties**
- 🔒 Alleen images uit **private ACR**
- 🔒 HTTPS geforceerd
- 🔒 Terraform backend gebruikt **Storage Account + container** met locking voor statefiles
- 🔒 **Managed Identity** gebruikt in plaats van service principal credentials
- 🔒 Key Vault alleen toegankelijk voor toegewezen identiteiten
- 🔒 De Terraform state file wordt opgeslagen in een beveiligde Azure Storage Account met een private container. Dit zorgt voor veilige opslag, versiebeheer en locking van de infrastructuurstatus
  

---

## 🧪 Monitoring

### Application Insights

- Real-time metrics en logging
- Traceer fouten, afhankelijkheden en requests
- Integratie via environment variables
- KQL (Kusto Query Language) support

Toegang:

1. Ga naar de Azure Portal
2. Open je Application Insights resource
3. Gebruik “Live Metrics”, “Failures”, “Performance”, etc.

### App Service Logging

- Log Stream toont stdout/stderr van de container
- Beschikbaar via Azure Portal → App Service → **Log Stream**

---

## 🚀 Getting Started

---

## ⚙️ Prerequisites (alleen voor eerste setup)

1. Omdat Terraform vereist dat de backend al bestaat voordat deze geconfigureerd kan worden, zijn de storage account en container eerst uitgerold. Vervolgens is de backend configuratie opgenomen in het terraform block zelf, zodat de state file automatisch wordt beheerd in Azure Storage.
```

2. Login bij Azure:

```bash
az login
```

---

## 🛠️ Installatie

```bash
cd terraform

terraform init
terraform validate
terraform workspace new test
terraform plan
terraform apply
```

---

## 🐳 Docker container builden & pushen

```bash
az acr login --name dasdemotestacr

docker build -t dasdemotestacr.azurecr.io/abhi-hello:latest .
docker push dasdemotestacr.azurecr.io/abhi-hello:latest
```

---

## 🧪 Lokaal draaien (optioneel)

```bash
docker build -t abhi-hello .
docker run -p 80:80 abhi-hello
```

Ga dan naar: [http://localhost:80](http://localhost:80)

---

## 📁 Projectstructuur

```text
.
├── app/
│   └── main.py
├── terraform/
│   ├── main.tf
│   ├── locals.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── Dockerfile
├── requirements.txt
└── README.md
```

---

## 👤 Contact

**Auteur:** Abhishek Kaul Kumar  
📧 abhi586@outlook.com 

---

## ✅ Status

✅ Volledig werkend, veilig en schaalbaar uitgerold op Azure  
📡 Monitoring geactiveerd  
🔒 Beveiliging met best practices geïmplementeerd  
