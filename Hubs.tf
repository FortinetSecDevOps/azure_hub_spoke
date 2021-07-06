//############################ Create Resource Group ##################

resource "azurerm_resource_group" "hubrg" {
  name     = "sallam-${var.az_project}-${var.az_TAG}"
  location = "westeurope"
}


//############################ Create Hub VNETs  ##################

resource "azurerm_virtual_network" "Hubs" {
  count               = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}"
  location            = var.az_hubsloc[count.index]
  resource_group_name = azurerm_resource_group.hubrg.name
  address_space       = [var.az_hubscidr[count.index]]

  tags = {
    Project = "${var.az_project}"
    Role    = "SecurityHub"
  }
}

//############################ Create Hub Subnets ##################
////////////Hub1

resource "azurerm_subnet" "Hub1SUbnets" {
  count                = length(var.az_hub1subnetscidrs)
  name                 = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = element(azurerm_virtual_network.Hubs.*.name, 0)
  address_prefixes     = [var.az_hub1subnetscidrs[count.index]]

}

//############################ Peer the Hubs ##################

///////Hub to spoke 1
resource "azurerm_virtual_network_peering" "hub1-to-spoke1" {
  name                      = "${var.az_project}-Hub-${var.az_hubsloc[0]}-to-spoke-${var.az_spokesloc[0]}"
  resource_group_name       = azurerm_resource_group.hubrg.name
  virtual_network_name      = element(azurerm_virtual_network.Hubs.*.name, 0)
  remote_virtual_network_id = element(azurerm_virtual_network.Spokes.*.id, 0)

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true


}

resource "azurerm_virtual_network_peering" "spoke1-to-hub1" {
  name                      = "${var.az_project}-spoke-${var.az_spokesloc[0]}-to-Hub-${var.az_hubsloc[0]}"
  resource_group_name       = azurerm_resource_group.hubrg.name
  virtual_network_name      = element(azurerm_virtual_network.Spokes.*.name, 0)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id, 0)

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}

/////Hub to spoke2

resource "azurerm_virtual_network_peering" "hub1-to-spoke2" {
  name                      = "${var.az_project}-Hub-${var.az_hubsloc[0]}-to-spoke-${var.az_spokesloc[1]}"
  resource_group_name       = azurerm_resource_group.hubrg.name
  virtual_network_name      = element(azurerm_virtual_network.Hubs.*.name, 0)
  remote_virtual_network_id = element(azurerm_virtual_network.Spokes.*.id, 1)

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true


}

resource "azurerm_virtual_network_peering" "spoke2-to-hub1" {
  name                      = "${var.az_project}-spoke-${var.az_spokesloc[1]}-to-Hub-${var.az_hubsloc[0]}"
  resource_group_name       = azurerm_resource_group.hubrg.name
  virtual_network_name      = element(azurerm_virtual_network.Spokes.*.name, 1)
  remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id, 0)

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}


//############################ Create RTB Hub1 ##################
resource "azurerm_route_table" "hub1_pub_RTB" {
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-pub_RTB"
  location            = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.az_project}"
  }
}
resource "azurerm_subnet_route_table_association" "hub1_pub_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id, 0)
  route_table_id = azurerm_route_table.hub1_pub_RTB.id
}

resource "azurerm_route" "hub1_pub_RTB_default" {
  name                = "defaultInternet"
  resource_group_name = azurerm_resource_group.hubrg.name
  route_table_name    = azurerm_route_table.hub1_pub_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

///////////////// Priv
resource "azurerm_route_table" "hub1_priv_RTB" {
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-priv_RTB"
  location            = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.az_project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub1_priv_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id, 1)
  route_table_id = azurerm_route_table.hub1_priv_RTB.id
}


resource "azurerm_route_table" "hub1_ha_RTB" {
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-ha_RTB"
  location            = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.az_project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub1_ha_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id, 2)
  route_table_id = azurerm_route_table.hub1_ha_RTB.id
}

///////////////// MGMT
resource "azurerm_route_table" "hub1_mgmt_RTB" {
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-mgmt_RTB"
  location            = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.az_project}"
  }
}

resource "azurerm_subnet_route_table_association" "hub1_mgmt_RTB_assoc" {
  subnet_id      = element(azurerm_subnet.Hub1SUbnets.*.id, 3)
  route_table_id = azurerm_route_table.hub1_mgmt_RTB.id
}

resource "azurerm_route" "hub1_mgmt_RTB_default" {
  name                = "defaultInternet"
  resource_group_name = azurerm_resource_group.hubrg.name
  route_table_name    = azurerm_route_table.hub1_mgmt_RTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

//############################ FGT11 NIC  ############################

resource "azurerm_network_interface" "fgt11nics" {
  count                         = length(var.az_fgt11ip)
  name                          = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-fgt1-port${count.index + 1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name           = azurerm_resource_group.hubrg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Hub1SUbnets.*.id, count.index)
    private_ip_address_allocation = "static"
    private_ip_address            = var.az_fgt11ip[count.index]
  }
}
//############################ FGT12 NIC  ############################
resource "azurerm_network_interface" "fgt12nics" {
  count                         = length(var.az_fgt12ip)
  name                          = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-fgt2-port${count.index + 1}"
  location                      = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name           = azurerm_resource_group.hubrg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Hub1SUbnets.*.id, count.index)
    private_ip_address_allocation = "static"
    private_ip_address            = var.az_fgt12ip[count.index]
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

/////////////////////////////////
resource "azurerm_network_interface_security_group_association" "fgt11priv" {
  network_interface_id      = azurerm_network_interface.fgt11nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt12priv" {
  network_interface_id      = azurerm_network_interface.fgt12nics.1.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_priv.0.id
}

////////////////////////////////

resource "azurerm_network_interface_security_group_association" "fgt11ha" {
  network_interface_id      = azurerm_network_interface.fgt11nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.0.id
}
resource "azurerm_network_interface_security_group_association" "fgt12ha" {
  network_interface_id      = azurerm_network_interface.fgt12nics.2.id
  network_security_group_id = azurerm_network_security_group.hub_fgt_nsg_ha.0.id
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

//############################ FGT11 and FGT12 VMs  ############################

data "template_file" "fgt11_customdata" {
  template = file("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id             = "fgt11"
    fgt_license_file   = ""
    fgt_username       = var.az_username
    fgt_config_ha      = true
    fgt_config_autoscale = false
    fgt_ssh_public_key = ""
    #role               = "master"
    #sync-port          = 

    Port1IP = var.az_fgt11ip[0]
    Port2IP = var.az_fgt11ip[1]
    Port3IP = var.az_fgt11ip[2]

    public_subnet_mask  = cidrnetmask(var.az_hub1subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.az_hub1subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.az_hub1subnetscidrs[2])

    fgt_external_gw = cidrhost(var.az_hub1subnetscidrs[0], 1)
    fgt_internal_gw = cidrhost(var.az_hub1subnetscidrs[1], 1)
    fgt_mgmt_gw     = cidrhost(var.az_hub1subnetscidrs[3], 1)


    fgt_ha_peerip   = var.az_fgt12ip[2]
    fgt_ha_priority = "100"
    vnet_network    = var.az_hubscidr[0]
  }
}

data "template_file" "fgt12_customdata" {
  template = file("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id             = "fgt12"
    fgt_license_file   = ""
    fgt_username       = var.az_username
    fgt_config_ha      = true
    fgt_config_autoscale = false
    fgt_ssh_public_key = ""

    Port1IP = var.az_fgt12ip[0]
    Port2IP = var.az_fgt12ip[1]
    Port3IP = var.az_fgt12ip[2]

    public_subnet_mask  = cidrnetmask(var.az_hub1subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.az_hub1subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.az_hub1subnetscidrs[2])

    fgt_external_gw = cidrhost(var.az_hub1subnetscidrs[0], 1)
    fgt_internal_gw = cidrhost(var.az_hub1subnetscidrs[1], 1)
    fgt_mgmt_gw     = cidrhost(var.az_hub1subnetscidrs[3], 1)


    fgt_ha_peerip   = var.az_fgt11ip[2]
    fgt_ha_priority = "50"
    vnet_network    = var.az_hubscidr[0]
  }
}

resource "azurerm_virtual_machine" "fgt11" {
  name                         = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-fgt1"
  location                     = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name          = azurerm_resource_group.hubrg.name
  network_interface_ids        = [azurerm_network_interface.fgt11nics.0.id, azurerm_network_interface.fgt11nics.1.id, azurerm_network_interface.fgt11nics.2.id, azurerm_network_interface.fgt11nics.3.id]
  primary_network_interface_id = element(azurerm_network_interface.fgt11nics.*.id, 0)
  vm_size                      = var.az_fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.az_FGT_IMAGE_SKU
    version   = var.az_FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.az_FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.az_project}_${var.az_TAG}_Hub_${var.az_hubsloc[0]}_fgt1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.az_project}_${var.az_TAG}_Hub_${var.az_hubsloc[0]}_fgt1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }
  os_profile {
    computer_name  = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-fgt1"
    admin_username = var.az_username
    admin_password = var.az_password
    custom_data    = data.template_file.fgt11_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [1]


  tags = {
    Project = "${var.az_project}"
    Role    = "FTNT"
  }

  depends_on = [azurerm_network_interface_backend_address_pool_association.ilb_backend_hub1_assoc_1, azurerm_network_interface_backend_address_pool_association.ilb_backend_hub1_assoc_2]


}

resource "azurerm_virtual_machine" "fgt12" {
  name                         = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-fgt2"
  location                     = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name          = azurerm_resource_group.hubrg.name
  network_interface_ids        = [azurerm_network_interface.fgt12nics.0.id, azurerm_network_interface.fgt12nics.1.id, azurerm_network_interface.fgt12nics.2.id, azurerm_network_interface.fgt12nics.3.id]
  primary_network_interface_id = element(azurerm_network_interface.fgt12nics.*.id, 0)
  vm_size                      = var.az_fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = var.az_FGT_IMAGE_SKU
    version   = var.az_FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = var.az_FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.az_project}_${var.az_TAG}_Hub_${var.az_hubsloc[0]}_fgt2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.az_project}_${var.az_TAG}_Hub_${var.az_hubsloc[0]}_fgt2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }


  os_profile {
    computer_name  = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-fgt2"
    admin_username = var.az_username
    admin_password = var.az_password
    custom_data    = data.template_file.fgt12_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [2]


  tags = {
    Project = "${var.az_project}"
    Role    = "FTNT"
  }

  depends_on = [azurerm_network_interface_backend_address_pool_association.ilb_backend_hub1_assoc_1, azurerm_network_interface_backend_address_pool_association.ilb_backend_hub1_assoc_2]



}

//############################ PIP and External LB  ####################
resource "azurerm_public_ip" "elbpip" {
  count               = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbpip"
  location            = element(azurerm_virtual_network.Hubs.*.location, count.index)
  resource_group_name = azurerm_resource_group.hubrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "elbs" {
  count               = length(var.az_hubsloc)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elb"
  location            = element(azurerm_virtual_network.Hubs.*.location, count.index)
  resource_group_name = azurerm_resource_group.hubrg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
    public_ip_address_id = element(azurerm_public_ip.elbpip.*.id, count.index)
  }
}


resource "azurerm_lb_backend_address_pool" "elb_backend" {
  count               = length(var.az_hubsloc)
  resource_group_name = azurerm_resource_group.hubrg.name
  loadbalancer_id     = element(azurerm_lb.elbs.*.id, count.index)
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elb-fgt-pool"
}

resource "azurerm_lb_probe" "elb_probe" {
  count               = length(var.az_hubsloc)
  resource_group_name = azurerm_resource_group.hubrg.name
  loadbalancer_id     = element(azurerm_lb.elbs.*.id, count.index)
  name                = "lbprobe-${var.az_lbprob}"
  port                = var.az_lbprob
  protocol            = "Tcp"
}

//////////////////

resource "azurerm_lb_rule" "elb_rule_udp500" {
  count                          = length(var.az_hubsloc)
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id, count.index)
  name                           = "elb-fgt-ike-udp-500"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
  probe_id                       = element(azurerm_lb_probe.elb_probe.*.id, count.index)
  backend_address_pool_id        = element(azurerm_lb_backend_address_pool.elb_backend.*.id, count.index)
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "elb_rule_udp4500" {
  count                          = length(var.az_hubsloc)
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id, count.index)
  name                           = "elb-fgt-ike-udp-4500"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
  probe_id                       = element(azurerm_lb_probe.elb_probe.*.id, count.index)
  backend_address_pool_id        = element(azurerm_lb_backend_address_pool.elb_backend.*.id, count.index)
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

//############################ Internal LB  ############################

resource "azurerm_lb" "ilb_hub1" {
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-ilb"
  location            = element(azurerm_virtual_network.Hubs.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-ilbip"
    subnet_id                     = element(azurerm_subnet.Hub1SUbnets.*.id, 1)
    private_ip_address            = var.az_ilbip[0]
    private_ip_address_allocation = "Static"
  }

  lifecycle {
    ignore_changes = all
  }
}
resource "azurerm_lb_probe" "ilb_hub1_probe" {
  resource_group_name = azurerm_resource_group.hubrg.name
  loadbalancer_id     = azurerm_lb.ilb_hub1.id
  name                = "lbprobe"
  port                = var.az_lbprob
  protocol            = "Tcp"
  interval_in_seconds = "10"
}

//==================================Internal LB Pools================================

resource "azurerm_lb_backend_address_pool" "ilb_backend_hub1" {
  resource_group_name = azurerm_resource_group.hubrg.name
  loadbalancer_id     = azurerm_lb.ilb_hub1.id
  name                = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-ilb-fgt-pool"
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

//==================================Internal LB Rules================================

resource "azurerm_lb_rule" "ilb1_haports_rule" {
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = azurerm_lb.ilb_hub1.id
  name                           = "ilb_haports_rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[0]}-ilbip"
  probe_id                       = azurerm_lb_probe.ilb_hub1_probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ilb_backend_hub1.id
  enable_floating_ip             = true
}


////////////NAT RULES

resource "azurerm_lb_nat_rule" "fgt11mgmthttps" {
  count                          = length(var.az_hubsloc)
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id, count.index)
  name                           = "fgt11-mgmt-40030"
  protocol                       = "Tcp"
  frontend_port                  = 40030
  backend_port                   = 34443
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
}

resource "azurerm_lb_nat_rule" "fgt12mgmthttps" {
  count                          = length(var.az_hubsloc)
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id, count.index)
  name                           = "fgt12-mgmt-40030"
  protocol                       = "Tcp"
  frontend_port                  = 40031
  backend_port                   = 34443
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
}

resource "azurerm_lb_nat_rule" "fgt11mgmtssh" {
  count                          = length(var.az_hubsloc)
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id, count.index)
  name                           = "fgt11-ssh-50030"
  protocol                       = "Tcp"
  frontend_port                  = 50030
  backend_port                   = 3422
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
}

resource "azurerm_lb_nat_rule" "fgt12mgmtssh" {
  count                          = length(var.az_hubsloc)
  resource_group_name            = azurerm_resource_group.hubrg.name
  loadbalancer_id                = element(azurerm_lb.elbs.*.id, count.index)
  name                           = "fgt12-ssh-50031"
  protocol                       = "Tcp"
  frontend_port                  = 50031
  backend_port                   = 3422
  frontend_ip_configuration_name = "${var.az_project}-${var.az_TAG}-Hub-${var.az_hubsloc[count.index]}-elbip"
}

//##########################Assign VM to NAT rule #######################

resource "azurerm_network_interface_nat_rule_association" "fgt11mgmthttpsvm" {
  network_interface_id    = azurerm_network_interface.fgt11nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgt11mgmthttps.0.id
}

resource "azurerm_network_interface_nat_rule_association" "fgt11mgmtsshvm" {
  network_interface_id    = azurerm_network_interface.fgt11nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgt11mgmtssh.0.id
}

resource "azurerm_network_interface_nat_rule_association" "fgt12mgmthttpsvm" {
  network_interface_id    = azurerm_network_interface.fgt12nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgt12mgmthttps.0.id
}

resource "azurerm_network_interface_nat_rule_association" "fgt12mgmtsshvm" {
  network_interface_id    = azurerm_network_interface.fgt12nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgt12mgmtssh.0.id
}







