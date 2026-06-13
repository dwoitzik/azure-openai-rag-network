# Azure AI Search & OpenAI: Automated Shared Private Link (RAG Base)

A minimal, targeted Infrastructure as Code (IaC) template demonstrating how to automate the creation and approval of Shared Private Links between Azure AI Search and Azure OpenAI — **completely eliminating the manual approval bottleneck** that breaks CI/CD pipelines.

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
                    │   (Embeddings / Chat)    │
                    └──────────────────────────┘
```

## 🚀 Features

- **Zero Manual Approval** — Automatically approves the Private Endpoint connection via AzAPI in the same `terraform apply` run
- **CI/CD Ready** — Eliminates the "Pending" state deadlock that breaks automated pipelines
- **Minimalist Base** — Perfect for testing RAG connectivity patterns without enterprise overhead
- **Parametrized Inputs** — Clean `variables.tf`, no hardcoded values

## 🛠️ Prerequisites

- Terraform `>= 1.5.0`
- AzAPI Provider `>= 1.13.0`
- Azure CLI (`az login`)
- Active Azure Subscription with permissions to create Cognitive Services and AI Search instances

## 📖 Usage

**1. Clone the repository**

```bash
git clone https://github.com/dwoitzik/azure-openai-rag-network.git
cd azure-openai-rag-network
```

**2. Configure your variables**

```bash
cp terraform.tfvars.example terraform.tfvars
```

```hcl
environment         = "demo"
rg_name             = "rg-ai-rag-base"
location            = "eastus"
openai_account_name = "oai-rag-demo"
search_service_name = "srch-rag-demo"
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
├── terraform.tfvars.example # Example configuration
└── README.md
```

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `openai_endpoint` | The endpoint URL of the deployed OpenAI account |
| `search_endpoint` | The endpoint URL of the AI Search service |
| `shared_link_status` | Approval status of the Shared Private Link |

## ⚠️ Known Limitations (Base Edition)

This template demonstrates the AzAPI auto-approval mechanism. **Do not deploy this directly into production** — without proper network isolation, you will face critical security issues:

- **No VNet Injection** — Services remain publicly accessible despite Private Link configuration
- **DNS Resolution Broken** — Missing `privatelink.openai.azure.com` Private DNS Zones will cause silent `403` errors
- **No Identity Chaining** — Disabling Local Auth without configuring Managed Identity RBAC breaks your application immediately
- **No Audit Trail** — Missing tags and lifecycle controls will cause drift against Azure Policy

---

## 📖 Deep Dive

Read the full technical breakdown — AzAPI state machine, Identity Chaining, and Private DNS automation explained step by step:

**[Automating Azure OpenAI RAG with Zero-Trust Networking →](https://woitzik.dev/blog/azure-rag-shared-private-link-automation)**

---

## 🔒 Need a Production-Ready Zero-Trust AI Architecture?

If you are building an AI assistant for enterprise clients, you cannot expose vector databases or OpenAI endpoints to the public internet, and you cannot rely on access keys.

In regulated environments (ISO 27001, NIS2), you will run into:

- **VNet Injection** — Private Endpoints for both services with correct subnet delegation
- **Automated DNS** — `privatelink.openai.azure.com` and `privatelink.search.windows.net` zones linked to your Hub VNet
- **Identity Chaining** — System Managed Identities with `Cognitive Services OpenAI User` RBAC, zero static keys

Getting all three right from scratch takes a senior engineer a full day of debugging `403` errors and DNS timeouts.

👉 **[Get the Enterprise AI RAG Blueprint →](https://woitzik-cloud.lemonsqueezy.com/checkout/buy/cd786faf-92b8-41c8-876e-c3a3fdf4f823)**
Full VNet isolation, automated DNS, RBAC Identity Chaining — ISO 27001 and NIS2 compliant on day one.

---

## 📄 License

MIT — free to use, modify, and distribute.

*Built by [David Woitzik](https://woitzik.dev) · [LinkedIn](https://linkedin.com/in/david-woitzik)*
