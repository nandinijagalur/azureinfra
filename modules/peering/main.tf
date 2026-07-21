# Hub -> Spoke peering (one per spoke, lives in hub's resource group)
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.spokes

  name                         = "peer-hub-to-${each.key}"
  resource_group_name         = var.hub_resource_group_name
  virtual_network_name        = var.hub_vnet_name
  remote_virtual_network_id   = each.value.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit         = true
  use_remote_gateways           = false
}

# Spoke -> Hub peering (one per spoke, lives in that spoke's resource group)
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.spokes

  name                         = "peer-${each.key}-to-hub"
  resource_group_name         = each.value.resource_group_name
  virtual_network_name        = each.value.vnet_name
  remote_virtual_network_id   = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}