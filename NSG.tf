//############################ Create FGT NSG ##################

resource "azurerm_network_security_group" "hub_fgt_nsg_pub" {
  count = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-pub-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSRG.name
}

  
resource "azurerm_network_security_rule" "fgt_nsg_pub_rule_egress" {
  count = length(var.hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_pub.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "fgt_nsg_pub_rule_ingress_1" {
  count = length(var.hubsloc)
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_pub.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}

///////////////////

resource "azurerm_network_security_group" "hub_fgt_nsg_priv" {
  count = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-priv-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSRG.name
}

  resource "azurerm_network_security_rule" "fgt_nsg_priv_rule_egress" {
  count = length(var.hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_priv.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "fgt_nsg_priv_rule_ingress_1" {
  count = length(var.hubsloc)
  name                        = "TCP_ALL"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_priv.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/8"
  destination_address_prefix  = "*"
  
} 
resource "azurerm_network_security_rule" "fgt_nsg_priv_rule_ingress_2" {
  count = length(var.hubsloc)
  name                        = "UDP_ALL"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_priv.*.name , count.index )
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/8"
  destination_address_prefix  = "*"
  
} 

/////////////////
resource "azurerm_network_security_group" "hub_fgt_nsg_ha" {
  count = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-ha-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSRG.name
}

  resource "azurerm_network_security_rule" "fgt_nsg_ha_rule_egress" {
  count = length(var.hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_ha.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.hubscidr[count.index]
  destination_address_prefix  = var.hubscidr[count.index]
    
}
resource "azurerm_network_security_rule" "fgt_nsg_ha_rule_ingress_1" {
  count = length(var.hubsloc)
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_ha.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.hubscidr[count.index]
  destination_address_prefix  = var.hubscidr[count.index]
} 


/////////////////

resource "azurerm_network_security_group" "fgt_nsg_hmgmt" {
  count                = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-mgmt-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSRG.name
}

  resource "azurerm_network_security_rule" "fgt_nsg_hmgmt_rule_egress" {
  count = length(var.hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.fgt_nsg_hmgmt.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "fgt_nsg_hmgmt_rule_ingress_1" {
  count = length(var.hubsloc)
  name                        = "adminhttps"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.fgt_nsg_hmgmt.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "34443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "fgt_nsg_hmgmt_rule_ingress_2" {
  count = length(var.hubsloc)
  name                        = "adminssh"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  network_security_group_name = element(azurerm_network_security_group.fgt_nsg_hmgmt.*.name , count.index )
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3422"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}

//############################ Backend Servers NSG ##################