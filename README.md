# Azure AI Search & OpenAI: Zero-Trust RAG Networking

[![CI](https://github.com/dwoitzik/azure-openai-rag-network/actions/workflows/tf-linter.yml/badge.svg)](https://github.com/dwoitzik/azure-openai-rag-network/actions/workflows/tf-linter.yml)

Infrastructure-as-Code for wiring up Azure AI Search and Azure OpenAI for Retrieval-Augmented Generation (RAG) workloads without exposing either service to the public internet or relying on API keys.

Both services sit behind Private Endpoints on a dedicated subnet, with matching Private DNS zones linked to the VNet, and AI Search reaches OpenAI via a System-Assigned Managed Identity with `Cognitive Services OpenAI User` RBAC — no shared keys, no manual Private Endpoint approval step, no public network access enabled anywhere in the path.

```text
                    ┌──────────────────────────┐
                    │   Azure AI Search        │
                    │   (Vector Store)         │
                    └────────────┬─────────────┘
                                 │  RBAC: Cognitive Services OpenAI User
                                 │  (Managed Identity, no keys)
                    ┌────────────▼─────────────┐
                    │   Azure OpenAI Service   │
                    │   (Embeddings / Chat)    │
                    └──────────────────────────┘
          both behind Private Endpoints on snet-private-endpoints,
          both public_network_access_enabled = false
```

## 🚀 Features

- **VNet-Isolated** — Both services reachable only via Private Endpoint; `public_network_access_enabled = false` on both.
- **Identity Chaining, No Keys** — AI Search authenticates to OpenAI via its own Managed Identity and an RBAC role assignment, not a shared access key.
- **Automated Private DNS** — `privatelink.openai.azure.com` and `privatelink.search.windows.net` zones created and linked to the VNet, so name resolution just works.
- **Deny-by-default NSG** on the Private Endpoints subnet.
- **Parametrized Inputs** — Clean `variables.tf`, no hardcoded values.

## 🛠️ Prerequisites

- Terraform `>= 1.5.0`
- Azure CLI (`az login`)
- Active Azure Subscription with permissions to create Cognitive Services and AI Search instances

## 📖 Usage

**1. Clone the repository**

```bash
git clone https://github.com/dwoitzik/azure-openai-rag-network.git
cd azure-openai-rag-network/terraform
```

**2. Configure your variables**

```bash
cp terraform.tfvars.example terraform.tfvars
```

```hcl
location             = "westeurope"
resource_group_name  = "rg-rag-blueprint"
openai_account_name  = "oai-rag-prod-001"   # must be globally unique
search_service_name  = "srch-rag-prod-001"  # must be globally unique
search_replica_count = 3                    # 3+ recommended for SLA; 1 for dev/test
```

**3. Deploy**

```bash
terraform init
terraform plan
terraform apply
```

Since both services are VNet-isolated, you'll need a client inside the VNet (a jumpbox, VPN, or peered network) to actually query them after deploying — that's the point.

## 📁 Repository Structure

```text
.
├── main.tf                  # VNet, Private DNS, OpenAI, AI Search, Private Endpoints, RBAC
├── providers.tf             # AzureRM Provider setup
├── variables.tf             # Input variable definitions
├── outputs.tf               # Private endpoint IPs & RBAC assignment ID
├── terraform.tfvars.example # Example configuration
└── README.md
```

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `vnet_name` | The name of the created Virtual Network |
| `openai_private_endpoint_ip` | Internal IP of the Azure OpenAI Private Endpoint |
| `search_private_endpoint_ip` | Internal IP of the Azure AI Search Private Endpoint |
| `rbac_assignment_id` | The RBAC role assignment granting Search access to OpenAI |

## ⚠️ Known Limitations

This module creates its own VNet (`10.0.0.0/16`) rather than injecting into an existing one — if you want this peered into a larger hub-and-spoke topology, peer `azurerm_virtual_network.vnet` manually or adapt the module to accept an existing VNet (see [azure-acme-cert-automation](https://github.com/dwoitzik/azure-acme-cert-automation) for that pattern). It also doesn't provision the client/jumpbox you'll need to actually reach these VNet-isolated endpoints.

---

## 📖 Deep Dive

Read the full technical breakdown — Private DNS automation, Identity Chaining, and why the old Shared-Private-Link-auto-approval approach was replaced with Private Endpoints:

**[Automating Azure OpenAI RAG with Zero-Trust Networking →](https://woitzik.dev/blog/azure-rag-shared-private-link-automation)**

---

## 📄 License

MIT — free to use, modify, and distribute.

*Built by [David Woitzik](https://woitzik.dev) · [LinkedIn](https://linkedin.com/in/david-woitzik)*
