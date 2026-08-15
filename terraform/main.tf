# ==========================================
# 1. Base Infrastructure & Networking
# ==========================================

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-enterprise-rag"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "endpoints_nsg" {
  name                = "nsg-rag-endpoints"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "deny-inbound-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "endpoints_nsg" {
  subnet_id                 = azurerm_subnet.endpoints.id
  network_security_group_id = azurerm_network_security_group.endpoints_nsg.id
}

# ==========================================
# 2. Private DNS Zones
# ==========================================

resource "azurerm_private_dns_zone" "openai_dns" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "search_dns" {
  name                = "privatelink.search.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_vnet_link" {
  name                  = "link-openai-vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.openai_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "search_vnet_link" {
  name                  = "link-search-vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.search_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# ==========================================
# 3. Azure OpenAI (Zero-Trust, VNet-isolated)
# ==========================================

resource "azurerm_cognitive_account" "openai" {
  #checkov:skip=CKV_AZURE_247: DLP for Cognitive Services requires Microsoft Defender for Cloud — enable at the subscription level separately.
  #checkov:skip=CKV2_AZURE_22: Customer-Managed Key for Cognitive Services requires a dedicated Key Vault and HSM — out of scope for this network layer module.
  name                  = var.openai_account_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = var.openai_account_name

  # Zero-trust security controls
  public_network_access_enabled = false
  local_auth_enabled            = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "pe_openai" {
  name                = "pe-openai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "psc-openai"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "dns-group-openai"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai_dns.id]
  }
}

# ==========================================
# 4. Azure AI Search (Zero-Trust, VNet-isolated)
# ==========================================

resource "azurerm_search_service" "search" {
  name                = var.search_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
  replica_count       = var.search_replica_count

  # Zero-trust security controls
  public_network_access_enabled = false
  local_authentication_enabled  = false

  # Crucial: Enable System Assigned Managed Identity for RBAC
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "pe_search" {
  name                = "pe-search"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "psc-search"
    private_connection_resource_id = azurerm_search_service.search.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  private_dns_zone_group {
    name                 = "dns-group-search"
    private_dns_zone_ids = [azurerm_private_dns_zone.search_dns.id]
  }
}

# ==========================================
# 5. Identity Chaining (RBAC Magic)
# ==========================================

# Grants the AI Search instance permission to read data from OpenAI
# without using API keys.
resource "azurerm_role_assignment" "search_to_openai" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_search_service.search.identity[0].principal_id
}
