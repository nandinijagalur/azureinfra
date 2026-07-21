resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  address_space       = var.hub_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "hub_subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}

# One NSG per subnet, except AzureBastionSubnet (Bastion has its own NSG requirements
# and Azure will complain if you try to over-restrict it manually while learning)
resource "azurerm_network_security_group" "hub_nsg" {
  for_each = { for k, v in var.subnets : k => v if k != "AzureBastionSubnet" }   #(k=>v Keep the same key and value).

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Basic deny-all-inbound-by-default rule (Azure already does this implicitly,
# but explicit is better than implicit when you're learning/auditing)
resource "azurerm_network_security_rule" "deny_inbound_internet" {
  for_each = azurerm_network_security_group.hub_nsg

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

resource "azurerm_subnet_network_security_group_association" "hub_nsg_assoc" {
  for_each = azurerm_network_security_group.hub_nsg

  subnet_id                 = azurerm_subnet.hub_subnets[each.key].id
  network_security_group_id = each.value.id
}