# Azure AI Search & OpenAI: Automated Shared Private Link (RAG Base)

A minimal, targeted Infrastructure as Code (IaC) template demonstrating how to automate the creation and approval of Shared Private Links between Azure AI Search and Azure OpenAI, **completely eliminating the manual approval bottleneck** that breaks CI/CD pipelines.

When building Retrieval-Augmented Generation (RAG) architectures, the native `azurerm` Terraform provider leaves Shared Private Links in a "Pending" state, forcing manual approval in the Azure Portal. This repository provides the clean, functional workaround using the `azapi` provider to programmatically force approval within the same Terraform run.

```text
                    ┌──────────────────────────┐
                    │   Azure AI Search        │
                    │   (Vector Store)         │
                    └────────────┬─────────────┘
                                 │
                    Shared Private Link (Auto-Approved)
                                 │
                    ┌────────────▼─────────────┐
                    │   Azure OpenAI Service   │
                    │   (Embeddings/Chat)      │
                    └──────────────────────────┘
```

## 🚀 Features

- **Zero Manual Approval** — Code structured to automatically approve the Private Endpoint connection via AzAPI.
- **CI/CD Ready** — Eliminates the "Pending" state deadlock that breaks automated deployments.
- **Minimalist Base** — Perfect for testing RAG connectivity patterns without enterprise overhead.
- **Parametrized Inputs** — Clean `variables.tf` to avoid hardcoded environments.

## 🛠️ Prerequisites

- Terraform `>= 1.5.0`
- Azure CLI (`az login`)
- An active Azure Subscription with permissions to create Cognitive Services and AI Search instances

## 📖 Usage
 **1. Clone the repository**
```bash
git clone https://github.com/dwoitzik/azure-openai-rag-network.git
cd azure-openai-rag-network
```
 **2. Configure your variables**
Create a `terraform.tfvars` file (or use default values):

```hcl
environment         = "demo"
rg_name             = "rg-ai-rag-base"
location            = "eastus"
openai_sku          = "S0"
search_sku          = "basic"
```
 **3. Deploy**
```bash
terraform init
terraform plan
terraform apply
```

## 📁 Repository Structure

```text
.
├── main.tf                  # AI Search, OpenAI & Shared Private Link logic
├── providers.tf             # AzureRM + AzAPI Provider setup
├── variables.tf             # Input variable definitions
├── outputs.tf               # Connection status & service endpoints
└── README.md
```

## ⚠️ Known Limitations (Base Edition)

This is a functional baseline that perfectly demonstrates the AzAPI auto-approval mechanism, but **DO NOT deploy this directly into production** . By exposing services to the public internet without proper network isolation, you will face critical security and access issues:

- **No VNet Injection:** Services remain publicly accessible despite Private Link configuration.
- **DNS Resolution Broken:** Missing `privatelink.openai.azure.com` Private DNS Zones will cause application failures.
- **403 Forbidden Errors:** Disabling Local Auth without configuring "Cognitive Services OpenAI User" and "Search Index Data Contributor" managed identities will immediately break your application.

---

## 🔒 Need a Production-Ready Zero-Trust AI Architecture?

If you are building an AI assistant for enterprise clients, you cannot expose your vector databases or OpenAI endpoints to the public internet, and you cannot rely on access keys. You need full VNet isolation and Identity Chaining.

👉 **[Get the Enterprise AI Infrastructure Blueprint →](#)** The Premium Edition is a plug-and-play Terraform module designed for strict regulatory compliance (ISO 27001 / NIS2). It includes:
- **Full VNet Integration:** Automated deployment of Private Endpoints for both AI Search and OpenAI.
- **Automated DNS:** Seamless creation and linking of Private DNS Zones to your Hub/Spoke architecture.
- **Identity Chaining:** Pre-configured System Assigned Managed Identities with perfectly scoped RBAC roles, eliminating 403 errors out of the box.

---

## 📄 License

MIT — free to use, modify, and distribute.

*Built by [David Woitzik](https://woitzik.dev) · [LinkedIn](https://linkedin.com/in/david-woitzik)*
