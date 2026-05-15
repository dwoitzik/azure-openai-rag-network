# ==========================================
# Outputs
# ==========================================

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "openai_endpoint" {
  description = "The endpoint URL for the Azure OpenAI instance"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "search_service_endpoint" {
  description = "The endpoint URL for the Azure AI Search instance"
  value       = "https://${azurerm_search_service.search.name}.search.windows.net"
}

output "shared_private_link_status" {
  description = "The name of the automated Shared Private Link"
  value       = azurerm_search_shared_private_link_service.openai_link.name
}
