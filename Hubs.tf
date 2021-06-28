
//############################ Create Resource Group ##################

resource "azurerm_resource_group" "COATSRG" {
  name     = "mremini-${var.project}-${var.TAG}"
  location = "westeurope"
}




//############################ Create Hub VNETs  ##################

resource "azurerm_virtual_network" "Hubs" {
  count = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}"
  location            =  var.hubsloc[count.index]
  resource_group_name = azurerm_resource_group.COATSRG.name
  address_space       = [ var.hubscidr[count.index] ]
  
  tags = {
    Project = "${var.project}"
    Role = "SecurityHub"
  }
}

//############################ Peer the Hubs ##################
resource "azurerm_virtual_network_peering" "hub1-to-hub2" {
  name                      = "${var.project}-Hub-${var.hubsloc[0]}-to-Hub-${var.hubsloc[1]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 0)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 1)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true


}
resource "azurerm_virtual_network_peering" "hub2-to-hub1" {
  name                      = "${var.project}-Hub-${var.hubsloc[1]}-to-Hub-${var.hubsloc[0]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 1)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 0)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}
////////////////
resource "azurerm_virtual_network_peering" "hub1-to-hub3" {
  name                      = "${var.project}-Hub-${var.hubsloc[0]}-to-Hub-${var.hubsloc[2]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 0)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 2)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true


}
resource "azurerm_virtual_network_peering" "hub3-to-hub1" {
  name                      = "${var.project}-Hub-${var.hubsloc[2]}-to-Hub-${var.hubsloc[0]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 2)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 0)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}
//////////////////
resource "azurerm_virtual_network_peering" "hub2-to-hub3" {
  name                      = "${var.project}-Hub-${var.hubsloc[1]}-to-Hub-${var.hubsloc[2]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 1)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 2)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true


}
resource "azurerm_virtual_network_peering" "hub3-to-hub2" {
  name                      = "${var.project}-Hub-${var.hubsloc[2]}-to-Hub-${var.hubsloc[1]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 2)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 1)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}


//############################ Create Hub Subnets ##################
////////////Hub1

resource "azurerm_subnet" "Hub1SUbnets" {
  count = length(var.hub1subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 0)
  address_prefixes     = [ var.hub1subnetscidrs[count.index]]

}

////////////Hub2

resource "azurerm_subnet" "Hub2SUbnets" {
  count = length(var.hub2subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 1)
  address_prefixes     = [ var.hub2subnetscidrs[count.index]]

}

////////////Hub3

resource "azurerm_subnet" "Hub3SUbnets" {
  count = length(var.hub3subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 2)
  address_prefixes     = [ var.hub3subnetscidrs[count.index]]

}


//############################ Create RTB Hub1 ##################
resource "azurerm_route_table" "hub1_pub_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-pub_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}
resource "azurerm_subnet_route_table_association" "hub1_pub_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id , 0)
  route_table_id = azurerm_route_table.hub1_pub_RTB.id
}

resource "azurerm_route" "hub1_pub_RTB_default" {
  name                = "defaultInternet"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name              = azurerm_route_table.hub1_pub_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

///////////////// Priv
resource "azurerm_route_table" "hub1_priv_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-priv_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub1_priv_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id , 1)
  route_table_id = azurerm_route_table.hub1_priv_RTB.id
}
////////Route Other Region Branches to their respective Hubs.

resource "azurerm_route" "hub1_priv_RTB_to_br21" {
  name                = "branch21"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.hub1_priv_RTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "hub1_priv_RTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.hub1_priv_RTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "hub1_priv_RTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.hub1_priv_RTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


///////////////// HA
resource "azurerm_route_table" "hub1_ha_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-ha_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub1_ha_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.hub1_ha_RTB.id
}

///////////////// MGMT
resource "azurerm_route_table" "hub1_mgmt_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-mgmt_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub1_mgmt_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id , 3)
  route_table_id = azurerm_route_table.hub1_mgmt_RTB.id
}

resource "azurerm_route" "hub1_mgmt_RTB_default" {
  name                = "defaultInternet"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name              = azurerm_route_table.hub1_mgmt_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}



//############################ Create RTB Hub2 ##################
resource "azurerm_route_table" "hub2_pub_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-pub_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}
resource "azurerm_subnet_route_table_association" "hub2_pub_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub2SUbnets.*.id , 0)
  route_table_id = azurerm_route_table.hub2_pub_RTB.id
}

resource "azurerm_route" "hub2_pub_RTB_default" {
  name                = "defaultInternet"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name              = azurerm_route_table.hub2_pub_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

///////////////// Priv
resource "azurerm_route_table" "hub2_priv_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-priv_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub2_priv_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub2SUbnets.*.id , 1)
  route_table_id = azurerm_route_table.hub2_priv_RTB.id
}

////////Route Other Region Branches to their respective Hubs.
resource "azurerm_route" "hub2_priv_RTB_to_br11" {
  name                = "branch11"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.hub2_priv_RTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "hub2_priv_RTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.hub2_priv_RTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "hub2_priv_RTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.hub2_priv_RTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

///////////////// HA
resource "azurerm_route_table" "hub2_ha_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-ha_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub2_ha_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub2SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.hub2_ha_RTB.id
}

///////////////// MGMT
resource "azurerm_route_table" "hub2_mgmt_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-mgmt_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub2_mgmt_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub2SUbnets.*.id , 3)
  route_table_id = azurerm_route_table.hub2_mgmt_RTB.id
}

resource "azurerm_route" "hub2_mgmt_RTB_default" {
  name                = "defaultInternet"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name              = azurerm_route_table.hub2_mgmt_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}


//############################ Create RTB Hub3 ##################
resource "azurerm_route_table" "hub3_pub_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-pub_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
     Project = "${var.project}"
  }
}
resource "azurerm_subnet_route_table_association" "hub3_pub_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub3SUbnets.*.id , 0)
  route_table_id = azurerm_route_table.hub3_pub_RTB.id
}

resource "azurerm_route" "hub3_pub_RTB_default" {
  name                = "defaultInternet"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name              = azurerm_route_table.hub3_pub_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

///////////////// Priv
resource "azurerm_route_table" "hub3_priv_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-priv_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub3_priv_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub3SUbnets.*.id , 1)
  route_table_id = azurerm_route_table.hub3_priv_RTB.id
}

///////////////// HA
resource "azurerm_route_table" "hub3_ha_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-ha_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub3_ha_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub3SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.hub3_ha_RTB.id
}

///////////////// MGMT
resource "azurerm_route_table" "hub3_mgmt_RTB" {
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-mgmt_RTB"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub3_mgmt_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub3SUbnets.*.id , 3)
  route_table_id = azurerm_route_table.hub3_mgmt_RTB.id
}

resource "azurerm_route" "hub3_mgmt_RTB_default" {
  name                = "defaultInternet"
  resource_group_name           = azurerm_resource_group.COATSRG.name
  route_table_name              = azurerm_route_table.hub3_mgmt_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}


//############################ FGT11 NIC  ############################
resource "azurerm_network_interface" "fgt11nics" {
  count = length(var.fgt11ip)
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-fgt1-port${count.index+1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Hub1SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgt11ip[count.index]
  }
}
//############################ FGT12 NIC  ############################
resource "azurerm_network_interface" "fgt12nics" {
  count = length(var.fgt12ip)
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-fgt2-port${count.index+1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Hub1SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgt12ip[count.index]
  }
}


//############################ FGT21 NIC  ############################
resource "azurerm_network_interface" "fgt21nics" {
  count = length(var.fgt21ip)
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt1-port${count.index+1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Hub2SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgt21ip[count.index]
  }
}
//############################ FGT22 NIC  ############################
resource "azurerm_network_interface" "fgt22nics" {
  count = length(var.fgt22ip)
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt2-port${count.index+1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Hub2SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgt22ip[count.index]
  }
}


//############################ FGT31 NIC  ############################
resource "azurerm_network_interface" "fgt31nics" {
  count = length(var.fgt31ip)
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-fgt1-port${count.index+1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  enable_ip_forwarding          = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Hub3SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgt31ip[count.index]
  }
}
//############################ FGT32 NIC  ############################

resource "azurerm_network_interface" "fgt32nics" {
  count = length(var.fgt32ip)
  name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-fgt2-port${count.index+1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Hub3SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgt32ip[count.index]
  }
}

//############################ NIC to NSG  ############################

resource "azurerm_network_interface_security_group_association" "fgt11pub" {
  network_interface_id      = azurerm_network_interface.fgt11nics.0.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_pub.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt12pub" {
  network_interface_id      = azurerm_network_interface.fgt12nics.0.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_pub.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt21pub" {
  network_interface_id      = azurerm_network_interface.fgt21nics.0.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_pub.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt22pub" {
  network_interface_id      = azurerm_network_interface.fgt22nics.0.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_pub.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt31pub" {
  network_interface_id      = azurerm_network_interface.fgt31nics.0.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_pub.2.id
}
resource "azurerm_network_interface_security_group_association" "fgt32pub" {
  network_interface_id      = azurerm_network_interface.fgt32nics.0.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_pub.2.id
}
/////////////////////////////////
resource "azurerm_network_interface_security_group_association" "fgt11priv" {
  network_interface_id      = azurerm_network_interface.fgt11nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt12priv" {
  network_interface_id      = azurerm_network_interface.fgt12nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt21priv" {
  network_interface_id      = azurerm_network_interface.fgt21nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt22priv" {
  network_interface_id      = azurerm_network_interface.fgt22nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt31priv" {
  network_interface_id      = azurerm_network_interface.fgt31nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.2.id
}
resource "azurerm_network_interface_security_group_association" "fgt32priv" {
  network_interface_id      = azurerm_network_interface.fgt32nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.2.id
}
/////////////////////////////////
resource "azurerm_network_interface_security_group_association" "fgt11ha" {
  network_interface_id      = azurerm_network_interface.fgt11nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt12ha" {
  network_interface_id      = azurerm_network_interface.fgt12nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt21ha" {
  network_interface_id      = azurerm_network_interface.fgt21nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt22ha" {
  network_interface_id      = azurerm_network_interface.fgt22nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt31ha" {
  network_interface_id      = azurerm_network_interface.fgt31nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.2.id
}
resource "azurerm_network_interface_security_group_association" "fgt32ha" {
  network_interface_id      = azurerm_network_interface.fgt32nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.2.id
}
/////////////////////////////////
resource "azurerm_network_interface_security_group_association" "fgt11mgmt" {
  network_interface_id      = azurerm_network_interface.fgt11nics.3.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg_hmgmt.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt12mgmt" {
  network_interface_id      = azurerm_network_interface.fgt12nics.3.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg_hmgmt.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt21mgmt" {
  network_interface_id      = azurerm_network_interface.fgt21nics.3.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg_hmgmt.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt22mgmt" {
  network_interface_id      = azurerm_network_interface.fgt22nics.3.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg_hmgmt.1.id
}
resource "azurerm_network_interface_security_group_association" "fgt31mgmt" {
  network_interface_id      = azurerm_network_interface.fgt31nics.3.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg_hmgmt.2.id
}
resource "azurerm_network_interface_security_group_association" "fgt32mgmt" {
  network_interface_id      = azurerm_network_interface.fgt32nics.3.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg_hmgmt.2.id
}


//############################ FGT11 and FGT12 VMs  ############################

data "template_file" "fgt11_customdata" {
  template = file ("./assets/fgt-userdata.tpl")
  vars = {
    fgt_id              = "fgt11"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_config_ha       = true
    fgt_ssh_public_key  = ""

    Port1IP             = var.fgt11ip[0]
    Port2IP             = var.fgt11ip[1]
    Port3IP             = var.fgt11ip[2]

    public_subnet_mask  = cidrnetmask(var.hub1subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.hub1subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.hub1subnetscidrs[2])

    fgt_external_gw     = cidrhost(var.hub1subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.hub1subnetscidrs[1], 1)
    fgt_mgmt_gw         = cidrhost(var.hub1subnetscidrs[3], 1)

  
    fgt_ha_peerip       = var.fgt12ip[2]
    fgt_ha_priority     = "100"
    vnet_network        = var.hubscidr[0]
  }
}

data "template_file" "fgt12_customdata" {
  template = file ("./assets/fgt-userdata.tpl")
  vars = {
    fgt_id              = "fgt12"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_config_ha       = true
    fgt_ssh_public_key  = ""

    Port1IP             = var.fgt12ip[0]
    Port2IP             = var.fgt12ip[1]
    Port3IP             = var.fgt12ip[2]

    public_subnet_mask  = cidrnetmask(var.hub1subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.hub1subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.hub1subnetscidrs[2])

    fgt_external_gw     = cidrhost(var.hub1subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.hub1subnetscidrs[1], 1)
    fgt_mgmt_gw         = cidrhost(var.hub1subnetscidrs[3], 1)

  
    fgt_ha_peerip       = var.fgt11ip[2]
    fgt_ha_priority     = "50"
    vnet_network        = var.hubscidr[0]
  }
} 

resource "azurerm_virtual_machine" "fgt11" {
  name                         = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-fgt1"
  location                     = element(azurerm_virtual_network.Hubs.*.location , 0 )
  resource_group_name          = azurerm_resource_group.COATSRG.name
  network_interface_ids        = [azurerm_network_interface.fgt11nics.0.id, azurerm_network_interface.fgt11nics.1.id, azurerm_network_interface.fgt11nics.2.id, azurerm_network_interface.fgt11nics.3.id]
  primary_network_interface_id = element (azurerm_network_interface.fgt11nics.*.id , 0)
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_Hub_${var.hubsloc[0]}_fgt1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Hub_${var.hubsloc[0]}_fgt1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-fgt1"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt11_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [1]


  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

} 

resource "azurerm_virtual_machine" "fgt12" {
  name                         = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-fgt2"
  location                     = element(azurerm_virtual_network.Hubs.*.location , 0 )
  resource_group_name          = azurerm_resource_group.COATSRG.name
  network_interface_ids        = [azurerm_network_interface.fgt12nics.0.id, azurerm_network_interface.fgt12nics.1.id, azurerm_network_interface.fgt12nics.2.id, azurerm_network_interface.fgt12nics.3.id]
  primary_network_interface_id = element (azurerm_network_interface.fgt12nics.*.id , 0)
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_Hub_${var.hubsloc[0]}_fgt2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Hub_${var.hubsloc[0]}_fgt2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }


  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-fgt2"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt12_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [2]


  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

} 

//############################ FGT21 and FGT22 VMs  ############################

data "template_file" "fgt21_customdata" {
  template = file ("./assets/fgt-userdata.tpl")
  vars = {
    fgt_id              = "fgt21"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_config_ha       = true
    fgt_ssh_public_key  = ""

    Port1IP             = var.fgt21ip[0]
    Port2IP             = var.fgt21ip[1]
    Port3IP             = var.fgt21ip[2]

    public_subnet_mask  = cidrnetmask(var.hub2subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.hub2subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.hub2subnetscidrs[2])

    fgt_external_gw     = cidrhost(var.hub2subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.hub2subnetscidrs[1], 1)
    fgt_mgmt_gw         = cidrhost(var.hub2subnetscidrs[3], 1)

  
    fgt_ha_peerip       = var.fgt22ip[2]
    fgt_ha_priority     = "100"
    vnet_network        = var.hubscidr[1]
  }
}

data "template_file" "fgt22_customdata" {
  template = file ("./assets/fgt-userdata.tpl")
  vars = {
    fgt_id              = "fgt22"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_config_ha       = true
    fgt_ssh_public_key  = ""

    Port1IP             = var.fgt22ip[0]
    Port2IP             = var.fgt22ip[1]
    Port3IP             = var.fgt22ip[2]

    public_subnet_mask  = cidrnetmask(var.hub2subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.hub2subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.hub2subnetscidrs[2])

    fgt_external_gw     = cidrhost(var.hub2subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.hub2subnetscidrs[1], 1)
    fgt_mgmt_gw         = cidrhost(var.hub2subnetscidrs[3], 1)

  
    fgt_ha_peerip       = var.fgt21ip[2]
    fgt_ha_priority     = "50"
    vnet_network        = var.hubscidr[1]
  }
} 

resource "azurerm_virtual_machine" "fgt21" {
  name                         = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt1"
  location                     = element(azurerm_virtual_network.Hubs.*.location , 1 )
  resource_group_name          = azurerm_resource_group.COATSRG.name
  network_interface_ids        = [azurerm_network_interface.fgt21nics.0.id, azurerm_network_interface.fgt21nics.1.id, azurerm_network_interface.fgt21nics.2.id, azurerm_network_interface.fgt21nics.3.id]
  primary_network_interface_id = element (azurerm_network_interface.fgt21nics.*.id , 0)
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_Hub_${var.hubsloc[1]}_fgt1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Hub_${var.hubsloc[1]}_fgt1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }


  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt1"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt21_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [1]
    

    tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

} 

resource "azurerm_virtual_machine" "fgt22" {
  name                         = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt2"
  location                     = element(azurerm_virtual_network.Hubs.*.location , 1 )
  resource_group_name          = azurerm_resource_group.COATSRG.name
  network_interface_ids        = [azurerm_network_interface.fgt22nics.0.id, azurerm_network_interface.fgt22nics.1.id, azurerm_network_interface.fgt22nics.2.id, azurerm_network_interface.fgt22nics.3.id]
  primary_network_interface_id = element (azurerm_network_interface.fgt22nics.*.id , 0)
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_Hub_${var.hubsloc[1]}_fgt2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Hub_${var.hubsloc[1]}_fgt2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }


  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt2"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt22_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [2]
    

    tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

}

//############################ FGT31 and FGT32 VMs  ############################

data "template_file" "fgt31_customdata" {
  template = file ("./assets/fgt-userdata.tpl")
  vars = {
    fgt_id              = "fgt31"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_config_ha       = true
    fgt_ssh_public_key  = ""

    Port1IP             = var.fgt31ip[0]
    Port2IP             = var.fgt31ip[1]
    Port3IP             = var.fgt31ip[2]

    public_subnet_mask  = cidrnetmask(var.hub3subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.hub3subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.hub3subnetscidrs[2])

    fgt_external_gw     = cidrhost(var.hub3subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.hub3subnetscidrs[1], 1)
    fgt_mgmt_gw         = cidrhost(var.hub3subnetscidrs[3], 1)

  
    fgt_ha_peerip       = var.fgt32ip[2]
    fgt_ha_priority     = "100"
    vnet_network        = var.hubscidr[2]
  }
}

data "template_file" "fgt32_customdata" {
  template = file ("./assets/fgt-userdata.tpl")
  vars = {
    fgt_id              = "fgt32"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_config_ha       = true
    fgt_ssh_public_key  = ""

    Port1IP             = var.fgt32ip[0]
    Port2IP             = var.fgt32ip[1]
    Port3IP             = var.fgt32ip[2]

    public_subnet_mask  = cidrnetmask(var.hub3subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.hub3subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.hub3subnetscidrs[2])

    fgt_external_gw     = cidrhost(var.hub3subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.hub3subnetscidrs[1], 1)
    fgt_mgmt_gw         = cidrhost(var.hub3subnetscidrs[3], 1)

  
    fgt_ha_peerip       = var.fgt31ip[2]
    fgt_ha_priority     = "50"
    vnet_network        = var.hubscidr[2]
  }
} 

resource "azurerm_virtual_machine" "fgt31" {
  name                         = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-fgt1"
  location                     = element(azurerm_virtual_network.Hubs.*.location , 2 )
  resource_group_name          = azurerm_resource_group.COATSRG.name
  network_interface_ids        = [azurerm_network_interface.fgt31nics.0.id, azurerm_network_interface.fgt31nics.1.id, azurerm_network_interface.fgt31nics.2.id, azurerm_network_interface.fgt31nics.3.id]
  primary_network_interface_id = element (azurerm_network_interface.fgt31nics.*.id , 0)
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_Hub_${var.hubsloc[2]}_fgt1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Hub_${var.hubsloc[2]}_fgt1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }


  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-fgt1"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt31_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }



  zones = [1]
    

    tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

} 

resource "azurerm_virtual_machine" "fgt32" {
  name                         = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-fgt2"
  location                     = element(azurerm_virtual_network.Hubs.*.location , 2 )
  resource_group_name          = azurerm_resource_group.COATSRG.name
  network_interface_ids        = [azurerm_network_interface.fgt32nics.0.id, azurerm_network_interface.fgt32nics.1.id, azurerm_network_interface.fgt32nics.2.id, azurerm_network_interface.fgt32nics.3.id]
  primary_network_interface_id = element (azurerm_network_interface.fgt32nics.*.id , 0)
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_Hub_${var.hubsloc[2]}_fgt2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Hub_${var.hubsloc[2]}_fgt2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }


  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-fgt2"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt32_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [2]
    

    tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }



} 

//############################ PIP and External LB  ####################

resource "azurerm_public_ip" "elbpip" {
  count = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-elbpip"
  location            = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "elbs" {
  count               = length(var.hubsloc)
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-elb"
  location            = element(azurerm_virtual_network.Hubs.*.location , count.index )
  resource_group_name = azurerm_resource_group.COATSRG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-elbip"
    public_ip_address_id          = element(azurerm_public_ip.elbpip.*.id , count.index )
  }
}


resource "azurerm_lb_backend_address_pool" "elb_backend" {
  count = length(var.hubsloc)
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = element(azurerm_lb.elbs.*.id , count.index )
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-elb-fgt-pool"
}

resource "azurerm_lb_probe" "elb_probe" {
  count = length(var.hubsloc)
  resource_group_name = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = element(azurerm_lb.elbs.*.id , count.index )
  name                = "lbprobe-${var.lbprob}"
  port                = var.lbprob
  protocol            ="Tcp"  
}
//////////////////

resource "azurerm_lb_rule" "elb_rule_udp500" {
  count                          = length(var.hubsloc)
  resource_group_name            = azurerm_resource_group.COATSRG.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id , count.index )
  name                           = "elb-fgt-ike-udp-500"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-elbip"
  probe_id                       = element(azurerm_lb_probe.elb_probe.*.id , count.index )
  backend_address_pool_id        = element(azurerm_lb_backend_address_pool.elb_backend.*.id , count.index )
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "elb_rule_udp4500" {
  count                          = length(var.hubsloc)
  resource_group_name            = azurerm_resource_group.COATSRG.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id , count.index )
  name                           = "elb-fgt-ike-udp-4500"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-Hub-${var.hubsloc[count.index]}-elbip"
  probe_id                       = element(azurerm_lb_probe.elb_probe.*.id , count.index )
  backend_address_pool_id        = element(azurerm_lb_backend_address_pool.elb_backend.*.id , count.index )
  enable_floating_ip             = false
  disable_outbound_snat          = true
}



//==================================External LB Nics Association=============================

resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_hub1_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgt11nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.0.id
}
resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_hub1_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgt12nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.0.id
}

resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_hub2_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgt21nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.1.id
}
resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_hub2_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgt22nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_hub3_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgt31nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.2.id
}
resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_hub3_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgt32nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend.2.id
}


//############################ Internal LB  ############################

resource "azurerm_lb" "ilb_hub1" {
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-ilb"
  location            =  element(azurerm_virtual_network.Hubs.*.location , 0 )
  resource_group_name = azurerm_resource_group.COATSRG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-ilbip"
    subnet_id                     = element(azurerm_subnet.Hub1SUbnets.*.id , 1)
    private_ip_address            = var.ilbip[0]
    private_ip_address_allocation = "Static"
  }

    lifecycle {
          ignore_changes = all
    }
}
resource "azurerm_lb_probe" "ilb_hub1_probe" {
  resource_group_name = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = azurerm_lb.ilb_hub1.id
  name                = "lbprobe"
  port                = var.lbprob
  protocol            ="Tcp" 
  interval_in_seconds = "10"
}

/////////////////////
resource "azurerm_lb" "ilb_hub2" {
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-ilb"
  location            =  element(azurerm_virtual_network.Hubs.*.location , 1 )
  resource_group_name = azurerm_resource_group.COATSRG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-ilbip"
    subnet_id                     = element(azurerm_subnet.Hub2SUbnets.*.id , 1)
    private_ip_address            = var.ilbip[1]
    private_ip_address_allocation = "Static"
  }

    lifecycle {
          ignore_changes = all
    }
}
resource "azurerm_lb_probe" "ilb_hub2_probe" {
  resource_group_name = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = azurerm_lb.ilb_hub2.id
  name                = "lbprobe-${var.lbprob}"
  port                = var.lbprob
  protocol            ="Tcp"
  interval_in_seconds = "10"
}

/////////////////////
resource "azurerm_lb" "ilb_hub3" {
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-ilb"
  location            =  element(azurerm_virtual_network.Hubs.*.location , 2 )
  resource_group_name = azurerm_resource_group.COATSRG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-ilbip"
    subnet_id                     = element(azurerm_subnet.Hub3SUbnets.*.id , 1)
    private_ip_address            = var.ilbip[2]
    private_ip_address_allocation = "Static"
  }

    lifecycle {
          ignore_changes = all
    }
}

resource "azurerm_lb_probe" "ilb_hub3_probe" {
  resource_group_name = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = azurerm_lb.ilb_hub3.id
  name                = "lbprobe-${var.lbprob}"
  port                = var.lbprob
  protocol            ="Tcp"  
  interval_in_seconds = "10"
}

//==================================Internal LB Pools================================

resource "azurerm_lb_backend_address_pool" "ilb_backend_hub1" {
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = azurerm_lb.ilb_hub1.id
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-ilb-fgt-pool"
}

resource "azurerm_lb_backend_address_pool" "ilb_backend_hub2" {
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = azurerm_lb.ilb_hub2.id
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-ilb-fgt-pool"
}

resource "azurerm_lb_backend_address_pool" "ilb_backend_hub3" {
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id     = azurerm_lb.ilb_hub3.id
  name                = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-ilb-fgt-pool"
}

//==================================Internal LB Nics Association=============================

resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_hub1_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgt11nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_hub1.id
}
resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_hub1_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgt12nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_hub1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_hub2_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgt21nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_hub2.id
}
resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_hub2_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgt22nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_hub2.id
}

resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_hub3_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgt31nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_hub3.id
}
resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_hub3_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgt32nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_hub3.id
}

//==================================Internal LB Rules================================

resource "azurerm_lb_rule" "ilb1_haports_rule" {
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id                 = azurerm_lb.ilb_hub1.id
  name                            = "ilb_haports_rule"
  protocol                        = "All"
  frontend_port                   = 0
  backend_port                    = 0
  frontend_ip_configuration_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[0]}-ilbip"
  probe_id                        = azurerm_lb_probe.ilb_hub1_probe.id
  backend_address_pool_id         = azurerm_lb_backend_address_pool.ilb_backend_hub1.id
  enable_floating_ip              = true
}

resource "azurerm_lb_rule" "ilb2_haports_rule" {
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id                 = azurerm_lb.ilb_hub2.id
  name                            = "ilb_haports_rule"
  protocol                        = "All"
  frontend_port                   = 0
  backend_port                    = 0
  frontend_ip_configuration_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[1]}-ilbip"
  probe_id                        = azurerm_lb_probe.ilb_hub2_probe.id
  backend_address_pool_id         = azurerm_lb_backend_address_pool.ilb_backend_hub2.id
  enable_floating_ip              = true
}

resource "azurerm_lb_rule" "ilb3_haports_rule" {
  resource_group_name           = azurerm_resource_group.COATSRG.name
  loadbalancer_id                 = azurerm_lb.ilb_hub3.id
  name                            = "ilb_haports_rule"
  protocol                        = "All"
  frontend_port                   = 0
  backend_port                    = 0
  frontend_ip_configuration_name  = "${var.project}-${var.TAG}-Hub-${var.hubsloc[2]}-ilbip"
  probe_id                        = azurerm_lb_probe.ilb_hub3_probe.id
  backend_address_pool_id         = azurerm_lb_backend_address_pool.ilb_backend_hub3.id
  enable_floating_ip              = true
}

