# ==========================================
# Input Variables
# ==========================================

variable "location" {
  description = "Azure Region for all resources (e.g., westeurope)"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-rag-automation-demo"
}

variable "openai_account_name" {
  description = "Globally unique name for the Azure OpenAI Cognitive Services Account"
  type        = string
  default     = "oai-rag-demo-dw-1337"
}

variable "search_service_name" {
  description = "Globally unique name for the Azure AI Search Service"
  type        = string
  default     = "srch-rag-demo-dw-1337"
}
