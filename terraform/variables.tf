# ==========================================
# Input Variables (Zero-Trust)
# ==========================================

variable "location" {
  description = "Azure Region for all resources (e.g., westeurope)"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-rag-blueprint"
}

variable "openai_account_name" {
  description = "Globally unique name for the Azure OpenAI Cognitive Services Account"
  type        = string
  default     = "oai-rag-prod-dw-1337"
}

variable "search_service_name" {
  description = "Globally unique name for the Azure AI Search Service"
  type        = string
  default     = "srch-rag-prod-dw-1337"
}

variable "search_replica_count" {
  description = "Number of AI Search replicas. Minimum 3 recommended for SLA on index updates and queries (CKV_AZURE_208/209). Set to 1 for dev/test."
  type        = number
  default     = 3
}
