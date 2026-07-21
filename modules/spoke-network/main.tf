resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  address_space       = var.spoke_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value]
  service_endpoints = ["Microsoft.Sql"]   # Lets this subnet's traffic be recognized by SQL VNet rules
}

resource "azurerm_network_security_group" "spoke_nsg" {
  for_each = var.subnets

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "deny_inbound_internet" {
  for_each = azurerm_network_security_group.spoke_nsg

  name                        = "Deny-Inbound-Internet"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = each.value.name
}

resource "azurerm_subnet_network_security_group_association" "spoke_nsg_assoc" {
  for_each = azurerm_network_security_group.spoke_nsg

  subnet_id                 = azurerm_subnet.spoke_subnets[each.key].id
  network_security_group_id = each.value.id
}