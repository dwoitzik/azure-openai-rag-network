# ==========================================
# Outputs
# ==========================================

output "vnet_name" {
  description = "The name of the injected Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "openai_private_endpoint_ip" {
  description = "The internal IP address of the Azure OpenAI instance"
  value       = azurerm_private_endpoint.pe_openai.private_service_connection[0].private_ip_address
}

output "search_private_endpoint_ip" {
  description = "The internal IP address of the Azure AI Search instance"
  value       = azurerm_private_endpoint.pe_search.private_service_connection[0].private_ip_address
}

output "rbac_assignment_id" {
  description = "The ID of the Role Assignment granting Search access to OpenAI"
  value       = azurerm_role_assignment.search_to_openai.id
}
