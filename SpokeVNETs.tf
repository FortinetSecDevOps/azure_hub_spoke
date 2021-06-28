//############################ Create Spoke VNETs  ##################

resource "azurerm_virtual_network" "Spokes" {
  count = length(var.spokesloc)
  name                = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[count.index]}"
  location            =  var.spokesloc[count.index]
  resource_group_name = azurerm_resource_group.COATSRG.name
  address_space       = [ var.spokescidr[count.index] ]
  
  tags = {
    Project = "${var.project}"
    Role = "SpokeVNET"
  }
}


//############################ Create Spoke Subnets and UDR ##################
////////////Spoke11

resource "azurerm_subnet" "Spoke11SUbnets" {
  count = length(var.spoke11subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[0]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , 0)
  address_prefixes     = [ var.spoke11subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke11privRTB" {
  name                          = "${var.project}-${var.TAG}-Spoke11_RTB"
  location                      =  var.spokesloc[0]
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke11privRTB_assoc" {
  count = length(var.spoke11subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke11SUbnets.*.id , count.index)
  route_table_id = azurerm_route_table.Spoke11privRTB.id
}

resource "azurerm_route" "Spoke11privRTB_to_br11" {
  name                = "branch11"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "Spoke11privRTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke11privRTB_to_br21" {
  name                = "branch21"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "Spoke11privRTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke11privRTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

//////////////Used to route back Health Checks////////

resource "azurerm_route" "Spoke11privRTB_to_europeipsec-1" {
  name                = "europe-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "192.168.10.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke11privRTB_to_europeipsec-2" {
  name                = "europe-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "192.168.11.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}


resource "azurerm_route" "Spoke11privRTB_to_usipsec-1" {
  name                = "us-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "192.168.20.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke11privRTB_to_usipsec-2" {
  name                = "us-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "192.168.21.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}


resource "azurerm_route" "Spoke11privRTB_to_apacipsec-1" {
  name                = "apac-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "192.168.30.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

resource "azurerm_route" "Spoke11privRTB_to_apacipsec-2" {
  name                = "apac-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke11privRTB.name
  address_prefix      = "192.168.31.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}



////////////Spoke12

resource "azurerm_subnet" "Spoke12SUbnets" {
  count = length(var.spoke12subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[1]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , 1)
  address_prefixes     = [ var.spoke12subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke12privRTB" {
  name                          = "${var.project}-${var.TAG}-Spoke12_RTB"
  location                      =  var.spokesloc[1]
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke12privRTB_assoc" {
  count = length(var.spoke12subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke12SUbnets.*.id , count.index)
  route_table_id = azurerm_route_table.Spoke12privRTB.id
}

resource "azurerm_route" "Spoke12privRTB_to_br11" {
  name                = "branch11"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "Spoke12privRTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke12privRTB_to_br21" {
  name                = "branch21"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "Spoke12privRTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke12privRTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


//////////////Used to route back Health Checks////////

resource "azurerm_route" "Spoke12privRTB_to_europeipsec-1" {
  name                = "europe-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "192.168.10.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke12privRTB_to_europeipsec-2" {
  name                = "europe-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "192.168.11.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}


resource "azurerm_route" "Spoke12privRTB_to_usipsec-1" {
  name                = "us-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "192.168.20.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke12privRTB_to_usipsec-2" {
  name                = "us-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "192.168.21.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}


resource "azurerm_route" "Spoke12privRTB_to_apacipsec-1" {
  name                = "apac-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "192.168.30.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

resource "azurerm_route" "Spoke12privRTB_to_apacipsec-2" {
  name                = "apac-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke12privRTB.name
  address_prefix      = "192.168.31.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

////////////Spoke21

resource "azurerm_subnet" "Spoke21SUbnets" {
  count = length(var.spoke21subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[2]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , 2)
  address_prefixes     = [ var.spoke21subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke21privRTB" {
  name                          = "${var.project}-${var.TAG}-Spoke21_RTB"
  location                      =  var.spokesloc[2]
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke21privRTB_assoc" {
  count = length(var.spoke21subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke21SUbnets.*.id , count.index)
  route_table_id = azurerm_route_table.Spoke21privRTB.id
}

resource "azurerm_route" "Spoke21privRTB_to_br11" {
  name                = "branch11"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "Spoke21privRTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke21privRTB_to_br21" {
  name                = "branch21"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "Spoke21privRTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke21privRTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


//////////////Used to route back Health Checks////////

resource "azurerm_route" "Spoke21privRTB_to_europeipsec-1" {
  name                = "europe-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "192.168.10.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke21privRTB_to_europeipsec-2" {
  name                = "europe-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "192.168.11.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}


resource "azurerm_route" "Spoke21privRTB_to_usipsec-1" {
  name                = "us-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "192.168.20.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke21privRTB_to_usipsec-2" {
  name                = "us-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "192.168.21.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}


resource "azurerm_route" "Spoke21privRTB_to_apacipsec-1" {
  name                = "apac-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "192.168.30.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

resource "azurerm_route" "Spoke21privRTB_to_apacipsec-2" {
  name                = "apac-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke21privRTB.name
  address_prefix      = "192.168.31.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


////////////Spoke22

resource "azurerm_subnet" "Spoke22SUbnets" {
  count = length(var.spoke22subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[3]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , 3)
  address_prefixes     = [ var.spoke22subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke22privRTB" {
  name                          = "${var.project}-${var.TAG}-Spoke22_RTB"
  location                      =  var.spokesloc[3]
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke22privRTB_assoc" {
  count = length(var.spoke22subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke22SUbnets.*.id , count.index)
  route_table_id = azurerm_route_table.Spoke22privRTB.id
}

resource "azurerm_route" "Spoke22privRTB_to_br11" {
  name                = "branch11"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "Spoke22privRTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke22privRTB_to_br21" {
  name                = "branch21"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "Spoke22privRTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke22privRTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


//////////////Used to route back Health Checks////////

resource "azurerm_route" "Spoke22privRTB_to_europeipsec-1" {
  name                = "europe-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "192.168.10.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke22privRTB_to_europeipsec-2" {
  name                = "europe-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "192.168.11.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}


resource "azurerm_route" "Spoke22privRTB_to_usipsec-1" {
  name                = "us-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "192.168.20.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke22privRTB_to_usipsec-2" {
  name                = "us-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "192.168.21.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}


resource "azurerm_route" "Spoke22privRTB_to_apacipsec-1" {
  name                = "apac-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "192.168.30.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

resource "azurerm_route" "Spoke22privRTB_to_apacipsec-2" {
  name                = "apac-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke22privRTB.name
  address_prefix      = "192.168.31.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

////////////Spoke31

resource "azurerm_subnet" "Spoke31SUbnets" {
  count = length(var.spoke31subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[4]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , 4)
  address_prefixes     = [ var.spoke31subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke31privRTB" {
  name                          = "${var.project}-${var.TAG}-Spoke31_RTB"
  location                      =  var.spokesloc[4]
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke31privRTB_assoc" {
  count = length(var.spoke31subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke31SUbnets.*.id , count.index)
  route_table_id = azurerm_route_table.Spoke31privRTB.id
}

resource "azurerm_route" "Spoke31privRTB_to_br11" {
  name                = "branch11"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "Spoke31privRTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke31privRTB_to_br21" {
  name                = "branch21"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "Spoke31privRTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke31privRTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


//////////////Used to route back Health Checks////////

resource "azurerm_route" "Spoke31privRTB_to_europeipsec-1" {
  name                = "europe-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "192.168.10.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke31privRTB_to_europeipsec-2" {
  name                = "europe-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "192.168.11.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}


resource "azurerm_route" "Spoke31privRTB_to_usipsec-1" {
  name                = "us-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "192.168.20.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke31privRTB_to_usipsec-2" {
  name                = "us-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "192.168.21.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}


resource "azurerm_route" "Spoke31privRTB_to_apacipsec-1" {
  name                = "apac-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "192.168.30.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

resource "azurerm_route" "Spoke31privRTB_to_apacipsec-2" {
  name                = "apac-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke31privRTB.name
  address_prefix      = "192.168.31.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


////////////Spoke32

resource "azurerm_subnet" "Spoke32SUbnets" {
  count = length(var.spoke32subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Spoke-${var.spokesloc[5]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , 5)
  address_prefixes     = [ var.spoke32subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke32privRTB" {
  name                          = "${var.project}-${var.TAG}-Spoke32_RTB"
  location                      =  var.spokesloc[5]
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke32privRTB_assoc" {
  count = length(var.spoke32subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke32SUbnets.*.id , count.index)
  route_table_id = azurerm_route_table.Spoke32privRTB.id
}

resource "azurerm_route" "Spoke32privRTB_to_br11" {
  name                = "branch11"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "172.16.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}
resource "azurerm_route" "Spoke32privRTB_to_br12" {
  name                = "branch12"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "172.17.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke32privRTB_to_br21" {
  name                = "branch21"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "172.20.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}
resource "azurerm_route" "Spoke32privRTB_to_br22" {
  name                = "branch22"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "172.21.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke32privRTB_to_br31" {
  name                = "branch31"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "172.30.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


//////////////Used to route-back Health Check Probes////////

resource "azurerm_route" "Spoke32privRTB_to_europeipsec-1" {
  name                = "europe-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "192.168.10.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}

resource "azurerm_route" "Spoke32privRTB_to_europeipsec-2" {
  name                = "europe-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "192.168.11.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[0]
}


resource "azurerm_route" "Spoke32privRTB_to_usipsec-1" {
  name                = "us-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "192.168.20.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}

resource "azurerm_route" "Spoke32privRTB_to_usipsec-2" {
  name                = "us-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "192.168.21.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[1]
}


resource "azurerm_route" "Spoke32privRTB_to_apacipsec-1" {
  name                = "apac-ipsec-isp1"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "192.168.30.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}

resource "azurerm_route" "Spoke32privRTB_to_apacipsec-2" {
  name                = "apac-ipsec-isp2"
  resource_group_name           =  azurerm_resource_group.COATSRG.name
  route_table_name    = azurerm_route_table.Spoke32privRTB.name
  address_prefix      = "192.168.31.0/24"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip[2]
}


//############################ Create Linux VMs inside Spokes ##################

data "template_file" "lnx_customdata" {
  template = "./assets/lnx-spoke.tpl"

  vars = {
  }
}


///////////////////LNX Spoke11

resource "azurerm_network_interface" "spoke11lnxnic" {
  name                            = "${var.project}-${var.TAG}-Spoke11-${var.spokesloc[0]}-lnx-port1"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke11SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke11lnx" {
  name                  = "spoke11lnx"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  network_interface_ids = [azurerm_network_interface.spoke11lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke11lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke11lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "LNX11"
  }

}

///////////////////LNX Spoke12

resource "azurerm_network_interface" "spoke12lnxnic" {
  name                            = "${var.project}-${var.TAG}-Spoke12-${var.spokesloc[1]}-lnx-port1"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke12SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke12lnx" {
  name                  = "spoke12lnx"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  network_interface_ids = [azurerm_network_interface.spoke12lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke12lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke12lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "LNX12"
  }

}

///////////////////LNX Spoke21

resource "azurerm_network_interface" "spoke21lnxnic" {
  name                            = "${var.project}-${var.TAG}-Spoke21-${var.spokesloc[2]}-lnx-port1"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke21SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke21lnx" {
  name                  = "spoke21lnx"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  network_interface_ids = [azurerm_network_interface.spoke21lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke21lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke21lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "LNX21"
  }

}

///////////////////LNX Spoke22

resource "azurerm_network_interface" "spoke22lnxnic" {
  name                            = "${var.project}-${var.TAG}-Spoke22-${var.spokesloc[3]}-lnx-port1"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 3)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke22SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke22lnx" {
  name                  = "spoke22lnx"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 3)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  network_interface_ids = [azurerm_network_interface.spoke22lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke22lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke22lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "LNX22"
  }

}

///////////////////LNX Spoke31

resource "azurerm_network_interface" "spoke31lnxnic" {
  name                            = "${var.project}-${var.TAG}-Spoke31-${var.spokesloc[4]}-lnx-port1"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 4)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke31SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke31lnx" {
  name                  = "spoke31lnx"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 4)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  network_interface_ids = [azurerm_network_interface.spoke31lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke31lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke31lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "LNX31"
  }

}

///////////////////LNX Spoke32

resource "azurerm_network_interface" "spoke32lnxnic" {
  name                            = "${var.project}-${var.TAG}-Spoke32-${var.spokesloc[5]}-lnx-port1"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 5)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke32SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke32lnx" {
  name                  = "spoke32lnx"
  location                      = element(azurerm_virtual_network.Spokes.*.location , 5)
  resource_group_name           = azurerm_resource_group.COATSRG.name

  network_interface_ids = [azurerm_network_interface.spoke32lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke32lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "spoke32lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "LNX32"
  }

}



//===================================================Spoke to Hubs peering===================================================



//--------Spokes To WestEuope Hub

resource "azurerm_virtual_network_peering" "spokes-to-westeuHub" {
  count = length(var.spokesloc)
  name                      = "Spoke-${var.spokesloc[count.index]}-to-Hub-westeurope"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , count.index )
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 0)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "westeuHub-To-Spokes" {
  count = length(var.spokesloc)
  name                      = "${var.project}-Hub-westeurope-to-Spoke-${var.spokesloc[count.index]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 0)
  remote_virtual_network_id = element(azurerm_virtual_network.Spokes.*.id , count.index )

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}


//--------Spokes To East US Hub

resource "azurerm_virtual_network_peering" "spokes-to-eastUSHub" {
  count = length(var.spokesloc)
  name                      = "Spoke-${var.spokesloc[count.index]}-to-Hub-eastus"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , count.index )
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 1)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "eastUSHub-To-Spokes" {
  count = length(var.spokesloc)
  name                      = "${var.project}-Hub-eastus-to-Spoke-${var.spokesloc[count.index]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 1)
  remote_virtual_network_id = element(azurerm_virtual_network.Spokes.*.id , count.index )

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}

//--------Spokes To SouthEastAsia Hub

resource "azurerm_virtual_network_peering" "spokes-to-southeastasiaHub" {
  count = length(var.spokesloc)
  name                      = "Spoke-${var.spokesloc[count.index]}-to-Hub-seasia"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name , count.index )
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id , 2)

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "southeastasiaHub-To-Spokes" {
  count = length(var.spokesloc)
  name                      = "${var.project}-Hub-seasia-to-Spoke-${var.spokesloc[count.index]}"
  resource_group_name = azurerm_resource_group.COATSRG.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name , 2)
  remote_virtual_network_id = element(azurerm_virtual_network.Spokes.*.id , count.index )

   allow_virtual_network_access = true
   allow_forwarded_traffic      = true

}

