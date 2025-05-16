
# 🚀 DAS - Technische Opdracht

**Live demo:** [https://dasdemo-test-app.azurewebsites.net](https://dasdemo-test-app.azurewebsites.net)

---

## 📌 Over dit project

Deze repository bevat een complete cloud-native webapplicatie gebaseerd op **Python (Flask)** die gecontaineriseerd is met **Docker** en uitgerold wordt op **Azure** via **Terraform**. De infrastructuur is volledig als code beschreven en omvat monitoring, veilige opslag van secrets en best practices op het gebied van cloudbeveiliging.

De applicatie toont een eenvoudige boodschap:

> “Hello from Abhishek!”

---

## 🧰 Tech Stack

- **Backend:** Python (Flask)
- **Containerisatie:** Docker
- **Infrastructure as Code:** Terraform
- **Cloud Platform:** Microsoft Azure (App Service, ACR, Key Vault, Application Insights, Storage Account)

---

## 🧱 Best Practices

- ✅ Infrastructure as Code via Terraform
- ✅ Secrets niet hardcoded
- ✅ Alleen private registries toegestaan
- ✅ Gebruik van HTTPS-only App Service
- ✅ Container draait als non-root gebruiker
- ✅ Monitoring via Application Insights
- ✅ Role-based access met Managed Identity
- ✅ Terraform state beveiligd en gelocked
- ✅ Tags en omgevingsscheiding via workspaces

---

## 🔐 Veiligheid

- 🔒 App draait als **non-root** gebruiker
- 🔒 **Secrets** worden opgehaald via **Key Vault referenties**
- 🔒 Alleen images uit **private ACR**
- 🔒 HTTPS geforceerd
- 🔒 Terraform backend gebruikt **Storage Account + container** met locking
- 🔒 **Managed Identity** gebruikt in plaats van service principal credentials
- 🔒 Key Vault alleen toegankelijk voor toegewezen identiteiten
- 🔒 Geen gevoelige gegevens in sourcecode

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
