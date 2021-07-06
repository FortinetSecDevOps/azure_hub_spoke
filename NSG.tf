
//############################ Create FGT NSG ##################

resource "azurerm_network_security_group" "hub_fgt_nsg_pub" {
  count = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-pub-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.hubrg.name
}

  
resource "azurerm_network_security_rule" "fgt_nsg_pub_rule_egress" {
  count = length(var.az_hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-priv-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.hubrg.name
}

  resource "azurerm_network_security_rule" "fgt_nsg_priv_rule_egress" {
  count = length(var.az_hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                        = "TCP_ALL"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                        = "UDP_ALL"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-ha-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.hubrg.name
}

  resource "azurerm_network_security_rule" "fgt_nsg_ha_rule_egress" {
  count = length(var.az_hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.hubrg.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_ha.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.az_hubscidr[count.index]
  destination_address_prefix  = var.az_hubscidr[count.index]
    
}
resource "azurerm_network_security_rule" "fgt_nsg_ha_rule_ingress_1" {
  count = length(var.az_hubsloc)
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.hubrg.name
  network_security_group_name = element(azurerm_network_security_group.hub_fgt_nsg_ha.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.az_hubscidr[count.index]
  destination_address_prefix  = var.az_hubscidr[count.index]
} 


/////////////////

resource "azurerm_network_security_group" "fgt_nsg_hmgmt" {
  count                = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-mgmt-nsg"
  location                      = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.hubrg.name
}

  resource "azurerm_network_security_rule" "fgt_nsg_hmgmt_rule_egress" {
  count = length(var.az_hubsloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                        = "adminhttps"
  resource_group_name           = azurerm_resource_group.hubrg.name
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
  count = length(var.az_hubsloc)
  name                        = "adminssh"
  resource_group_name           = azurerm_resource_group.hubrg.name
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




//############################ Create FGT branch NSG ##################

resource "azurerm_network_security_group" "branch_fgt_nsg_pub" {
  count = length(var.az_branchesloc)
  name                = "${var.az_project}-${var.az_TAG}-branch-${var.az_branchesloc[count.index]}-pub-nsg"
  location                      = element(azurerm_virtual_network.branches.*.location , count.index )
  resource_group_name           = azurerm_resource_group.branchrg.name
}

  
resource "azurerm_network_security_rule" "branch_fgt_nsg_pub_rule_egress" {
  count = length(var.az_branchesloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_pub.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "branch_fgt_nsg_pub_rule_ingress_1" {
  count = length(var.az_branchesloc)
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_pub.*.name , count.index )
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

resource "azurerm_network_security_group" "branch_fgt_nsg_priv" {
  count = length(var.az_branchesloc)
  name                = "${var.az_project}-${var.az_TAG}-branch-${var.az_branchesloc[count.index]}-priv-nsg"
  location                      = element(azurerm_virtual_network.branches.*.location , count.index )
  resource_group_name           = azurerm_resource_group.branchrg.name
}

  resource "azurerm_network_security_rule" "branch_fgt_nsg_priv_rule_egress" {
  count = length(var.az_branchesloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_priv.*.name , count.index )
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "branch_fgt_nsg_priv_rule_ingress_1" {
  count = length(var.az_branchesloc)
  name                        = "TCP_ALL"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_priv.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/8"
  destination_address_prefix  = "*"
  
} 
resource "azurerm_network_security_rule" "branch_fgt_nsg_priv_rule_ingress_2" {
  count = length(var.az_branchesloc)
  name                        = "UDP_ALL"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_priv.*.name , count.index )
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
resource "azurerm_network_security_group" "branch1_fgt_nsg_ha" {
  name                = "${var.az_project}-${var.az_TAG}-branch-${var.az_branchesloc[0]}-ha-nsg"
  location                      = azurerm_virtual_network.branches.0.location
  resource_group_name           = azurerm_resource_group.branchrg.name
}

  resource "azurerm_network_security_rule" "branch1_fgt_nsg_ha_rule_egress" {
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = azurerm_network_security_group.branch1_fgt_nsg_ha.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.az_branchescidr[0]
  destination_address_prefix  = var.az_branchescidr[0]
    
}
resource "azurerm_network_security_rule" "branch1_fgt_nsg_ha_rule_ingress_1" {
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = azurerm_network_security_group.branch1_fgt_nsg_ha.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.az_branchescidr[0]
  destination_address_prefix  = var.az_branchescidr[0]
} 


/////////////////

resource "azurerm_network_security_group" "branch1_fgt_nsg_hmgmt" {
  name                = "${var.az_project}-${var.az_TAG}-branch-${var.az_branchesloc[0]}-mgmt-nsg"
  location                      = azurerm_virtual_network.branches.0.location
  resource_group_name           = azurerm_resource_group.branchrg.name
}

  resource "azurerm_network_security_rule" "branch1_fgt_nsg_hmgmt_rule_egress" {
  
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = azurerm_network_security_group.branch1_fgt_nsg_hmgmt.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "branch1_fgt_nsg_hmgmt_rule_ingress_1" {
  name                        = "adminhttps"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name = azurerm_network_security_group.branch1_fgt_nsg_hmgmt.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "34443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}
resource "azurerm_network_security_rule" "branch1_fgt_nsg_hmgmt_rule_ingress_2" {
  name                        = "adminssh"
  resource_group_name           = azurerm_resource_group.branchrg.name
  network_security_group_name =  azurerm_network_security_group.branch1_fgt_nsg_hmgmt.name 
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3422"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}