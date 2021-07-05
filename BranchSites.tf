//############################ Create Resource Group ##################
resource "azurerm_resource_group" "branchrg" {
  name     = "sallam-${var.project}-${var.TAG}-Branches"
  location = "westeurope"
}

//############################ Create Branch Sites VNETs  ##################

resource "azurerm_virtual_network" "branches" {
  count               = length(var.branchesloc)
  name                = "${var.project}-${var.TAG}-branch-${var.branchesloc[count.index]}"
  location            = var.branchesloc[count.index]
  resource_group_name = azurerm_resource_group.branchrg.name
  address_space       = [var.branchescidr[count.index]]

  tags = {
    Project = "${var.project}"
    Role    = "BranchSite"
  }
}

//############################ Create Branch Site Subnets ##################
////////////Branch11

resource "azurerm_subnet" "Branch11SUbnets" {
  count                = length(var.branch11subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.branchrg.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name, 0)
  address_prefixes     = [var.branch11subnetscidrs[count.index]]

}
////////////Branch21

resource "azurerm_subnet" "Branch21SUbnets" {
  count                = length(var.branch21subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.branchrg.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name, 1)
  address_prefixes     = [var.branch21subnetscidrs[count.index]]

}

//############################ Create NICs ##################
/////////////////////Branch 11 NIC

resource "azurerm_network_interface" "fgtbranch11nics" {
  count                         = length(var.fgtbranch11ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgtbranch11-port${count.index + 1}"
  location                      = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name           = azurerm_resource_group.branchrg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch11SUbnets.*.id, count.index)
    private_ip_address_allocation = "static"
    private_ip_address            = var.fgtbranch11ip[count.index]
  }

  lifecycle {
    ignore_changes = all
  }


}

resource "azurerm_network_interface" "fgtbranch12nics" {
  count                         = length(var.fgtbranch12ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgtbranch12-port${count.index + 1}"
  location                      = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name           = azurerm_resource_group.branchrg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch11SUbnets.*.id, count.index)
    private_ip_address_allocation = "static"
    private_ip_address            = var.fgtbranch12ip[count.index]

  }
  lifecycle {
    ignore_changes = all
  }

}

/////////////////////Branch 21 NIC

resource "azurerm_network_interface" "fgtbranch21nics" {
  count                         = length(var.fgtbranch21ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgtbranch21-port${count.index + 1}"
  location                      = element(azurerm_virtual_network.branches.*.location, 1)
  resource_group_name           = azurerm_resource_group.branchrg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch21SUbnets.*.id, count.index)
    private_ip_address_allocation = "static"
    private_ip_address            = var.fgtbranch21ip[count.index]
  }

  #lifecycle {
   # ignore_changes = all
  #}

}
//////////// Branch 21 public ip association to port1 
resource "azurerm_network_interface" "fgtbranch21nics_publicip" {
  name                          = azurerm_network_interface.fgtbranch21nics.0.name
  location                      = element(azurerm_virtual_network.branches.*.location, 1)
  resource_group_name           = azurerm_resource_group.branchrg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.Branch21SUbnets.0.id
    private_ip_address_allocation = "static"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.fgtbranch21pip.id

  }

  #lifecycle {
   # ignore_changes = all
  #}

}

//############################ FGT VM ##################

data "template_file" "fgtbranch11_customdata" {
  template = file("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id               = "fgtbranch11"
    fgt_license_file     = ""
    fgt_username         = var.username
    fgt_ssh_public_key   = ""
    fgt_config_ha        = true
    fgt_config_autoscale = false

    Port1IP = var.fgtbranch11ip[0]
    Port2IP = var.fgtbranch11ip[1]
    Port3IP = var.fgtbranch11ip[3]

    public_subnet_mask  = cidrnetmask(var.branch11subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch11subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.branch11subnetscidrs[2])

    fgt_external_gw = cidrhost(var.branch11subnetscidrs[0], 1)
    fgt_internal_gw = cidrhost(var.branch11subnetscidrs[1], 1)
    fgt_mgmt_gw     = cidrhost(var.branch11subnetscidrs[3], 1)

    vnet_network    = var.branchescidr[0]
    fgt_ha_peerip   = var.fgtbranch12ip[2]
    fgt_ha_priority = "100"
  }
}

data "template_file" "fgtbranch12_customdata" {
  template = file("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id               = "fgtbranch12"
    fgt_license_file     = ""
    fgt_username         = var.username
    fgt_ssh_public_key   = ""
    fgt_config_ha        = true
    fgt_config_autoscale = false

    Port1IP = var.fgtbranch12ip[0]
    Port2IP = var.fgtbranch12ip[1]
    Port3IP = var.fgtbranch12ip[3]

    public_subnet_mask  = cidrnetmask(var.branch11subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch11subnetscidrs[1])
    ha_subnet_mask      = cidrnetmask(var.branch11subnetscidrs[2])

    fgt_external_gw = cidrhost(var.branch11subnetscidrs[0], 1)
    fgt_internal_gw = cidrhost(var.branch11subnetscidrs[1], 1)
    fgt_mgmt_gw     = cidrhost(var.branch11subnetscidrs[3], 1)

    vnet_network    = var.branchescidr[0]
    fgt_ha_peerip   = var.fgtbranch11ip[2]
    fgt_ha_priority = "50"
  }
}

resource "azurerm_virtual_machine" "fgtbranch11" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgt11"
  location                     = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name          = azurerm_resource_group.branchrg.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch11nics.0.id, azurerm_network_interface.fgtbranch11nics.1.id, azurerm_network_interface.fgtbranch11nics.2.id, azurerm_network_interface.fgtbranch11nics.3.id]
  primary_network_interface_id = element(azurerm_network_interface.fgtbranch11nics.*.id, 0)
  vm_size                      = var.fgtbranch_vmsize

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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[0]}_fgt11_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[0]}_fgt11_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgt11"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch11_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  #zones = [1]

  tags = {
    Project = "${var.project}"
    Role    = "FTNT"
  }
  depends_on = [azurerm_network_interface_backend_address_pool_association.ilb_backend_branch1_assoc_1, azurerm_network_interface_backend_address_pool_association.ilb_backend_branch1_assoc_2]
}

resource "azurerm_virtual_machine" "fgtbranch12" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgt12"
  location                     = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name          = azurerm_resource_group.branchrg.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch12nics.0.id, azurerm_network_interface.fgtbranch12nics.1.id, azurerm_network_interface.fgtbranch12nics.2.id, azurerm_network_interface.fgtbranch12nics.3.id]
  primary_network_interface_id = element(azurerm_network_interface.fgtbranch12nics.*.id, 0)
  vm_size                      = var.fgtbranch_vmsize

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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[0]}_fgt12_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[0]}_fgt12_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgt12"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch12_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  #zones = [2]

  tags = {
    Project = "${var.project}"
    Role    = "FTNT"
  }
  depends_on = [azurerm_network_interface_backend_address_pool_association.ilb_backend_branch1_assoc_1, azurerm_network_interface_backend_address_pool_association.ilb_backend_branch1_assoc_2]
}

/////////////////////////////////////////////////// branch21


data "template_file" "fgtbranch21_customdata" {
  template = file("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id               = "fgtbranch21"
    fgt_license_file     = ""
    fgt_username         = var.username
    fgt_ssh_public_key   = ""
    fgt_config_ha        = false
    fgt_config_autoscale = false

    Port1IP = var.fgtbranch21ip[0]
    Port2IP = var.fgtbranch21ip[1]

    public_subnet_mask  = cidrnetmask(var.branch21subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch21subnetscidrs[1])

    fgt_external_gw = cidrhost(var.branch21subnetscidrs[0], 1)
    fgt_internal_gw = cidrhost(var.branch21subnetscidrs[1], 1)

    vnet_network = var.branchescidr[1]
  }
}

resource "azurerm_virtual_machine" "fgtbranch21" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgt21"
  location                     = element(azurerm_virtual_network.branches.*.location, 1)
  resource_group_name          = azurerm_resource_group.branchrg.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch21nics.0.id, azurerm_network_interface.fgtbranch21nics.1.id, azurerm_network_interface.fgtbranch21nics.2.id]
  primary_network_interface_id = element(azurerm_network_interface.fgtbranch21nics.*.id, 0)
  vm_size                      = var.fgtbranch_vmsize

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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[1]}_fgt21_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[1]}_fgt21_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgt21"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch21_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role    = "FTNT"
  }

}

//############################ PIP and External LB  ####################

resource "azurerm_public_ip" "elbpip_branch1" {
  name                = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbpip"
  location            = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name = azurerm_resource_group.branchrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "elbs_branch1" {
  name                = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elb"
  location            = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name = azurerm_resource_group.branchrg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
    public_ip_address_id = azurerm_public_ip.elbpip_branch1.id
  }
}

resource "azurerm_lb_backend_address_pool" "elb_backend_branch1" {
  resource_group_name = azurerm_resource_group.branchrg.name
  loadbalancer_id     = azurerm_lb.elbs_branch1.id
  name                = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elb-fgt-pool"
}

resource "azurerm_lb_probe" "elb_probe_branch1" {
  resource_group_name = azurerm_resource_group.branchrg.name
  loadbalancer_id     = azurerm_lb.elbs_branch1.id
  name                = "lbprobe-${var.lbprob}"
  port                = var.lbprob
  protocol            = "Tcp"
}

//////////////////elb rules

resource "azurerm_lb_rule" "elb_rule_udp500_branch1" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = element(azurerm_lb.elbs_branch1.*.id, 0)
  name                           = "elb-fgt-ike-udp-500"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
  probe_id                       = element(azurerm_lb_probe.elb_probe_branch1.*.id, 0)
  backend_address_pool_id        = element(azurerm_lb_backend_address_pool.elb_backend_branch1.*.id, 0)
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "elb_rule_udp4500_branch1" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = element(azurerm_lb.elbs_branch1.*.id, 0)
  name                           = "elb-fgt-ike-udp-4500"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
  probe_id                       = element(azurerm_lb_probe.elb_probe_branch1.*.id, 0)
  backend_address_pool_id        = element(azurerm_lb_backend_address_pool.elb_backend_branch1.*.id, 0)
  enable_floating_ip             = false
  disable_outbound_snat          = true
}


//############################ External LB Nics Association ####################

resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_branch1_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgtbranch11nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend_branch1.id
}
resource "azurerm_network_interface_backend_address_pool_association" "elb_backend_branch1_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgtbranch12nics.0.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elb_backend_branch1.id
}

//############################ Internal LB  ############################

resource "azurerm_lb" "ilb_branch1" {
  name                = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-ilb"
  location            = element(azurerm_virtual_network.branches.*.location, 0)
  resource_group_name = azurerm_resource_group.branchrg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-ilbip"
    subnet_id                     = element(azurerm_subnet.Branch11SUbnets.*.id, 1)
    private_ip_address            = var.ilbip_branch1[0]
    private_ip_address_allocation = "Static"
  }

  lifecycle {
    ignore_changes = all
  }
}
resource "azurerm_lb_probe" "ilb_branch1_probe" {
  resource_group_name = azurerm_resource_group.branchrg.name
  loadbalancer_id     = azurerm_lb.ilb_branch1.id
  name                = "lbprobe"
  port                = var.lbprob
  protocol            = "Tcp"
  interval_in_seconds = "10"
}

//==================================Internal LB Pools================================

resource "azurerm_lb_backend_address_pool" "ilb_backend_branch1" {
  resource_group_name = azurerm_resource_group.branchrg.name
  loadbalancer_id     = azurerm_lb.ilb_branch1.id
  name                = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-ilb-fgt-pool"
}

//==================================Internal LB Nics Association=============================

resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_branch1_assoc_1" {
  network_interface_id    = azurerm_network_interface.fgtbranch11nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_branch1.id
}
resource "azurerm_network_interface_backend_address_pool_association" "ilb_backend_branch1_assoc_2" {
  network_interface_id    = azurerm_network_interface.fgtbranch12nics.1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend_branch1.id
}

//==================================Internal LB Rules================================

resource "azurerm_lb_rule" "ilb1_branch1_haports_rule" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = azurerm_lb.ilb_branch1.id
  name                           = "ilb_haports_rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-ilbip"
  probe_id                       = azurerm_lb_probe.ilb_branch1_probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ilb_backend_branch1.id
  enable_floating_ip             = true
}

//############################## FG 21 PUBLIC IP #######################

resource "azurerm_public_ip" "fgtbranch21pip" {
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgt21pip"
  location            = element(azurerm_virtual_network.branches.*.location, 1)
  resource_group_name = azurerm_resource_group.branchrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# ///////////// VNET peering 
# resource "azurerm_virtual_network_peering" "hub1-to-branch1" {
#   name                      = "${var.project}-Hub-${var.hubsloc[0]}-to-branch-${var.branchesloc[0]}"
#   resource_group_name       = azurerm_resource_group.hubrg.name
#   virtual_network_name      = element(azurerm_virtual_network.Hubs.*.name, 0)
#   remote_virtual_network_id = element(azurerm_virtual_network.branches.*.id, 0)

#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true


# }

# resource "azurerm_virtual_network_peering" "branch1-to-hub1" {
#   name                      = "${var.project}-branch-${var.branchesloc[0]}-to-Hub-${var.hubsloc[0]}"
#   resource_group_name       = azurerm_resource_group.branchrg.name
#   virtual_network_name      = element(azurerm_virtual_network.branches.*.name, 0)
#   remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id, 0)

#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true

# }

# resource "azurerm_virtual_network_peering" "hub1-to-branch2" {
#   name                      = "${var.project}-Hub-${var.hubsloc[0]}-to-branch-${var.branchesloc[1]}"
#   resource_group_name       = azurerm_resource_group.hubrg.name
#   virtual_network_name      = element(azurerm_virtual_network.Hubs.*.name, 0)
#   remote_virtual_network_id = element(azurerm_virtual_network.branches.*.id, 1)

#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true


# }

# resource "azurerm_virtual_network_peering" "branch2-to-hub1" {
#   name                      = "${var.project}-branch-${var.branchesloc[1]}-to-Hub-${var.hubsloc[0]}"
#   resource_group_name       = azurerm_resource_group.branchrg.name
#   virtual_network_name      = element(azurerm_virtual_network.branches.*.name, 1)
#   remote_virtual_network_id = element(azurerm_virtual_network.Hubs.*.id, 0)

#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true

# }

resource "azurerm_lb_nat_rule" "fgtbranch11mgmthttps" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = azurerm_lb.elbs_branch1.id
  name                           = "fgtbranch11-mgmt-40030"
  protocol                       = "Tcp"
  frontend_port                  = 40030
  backend_port                   = 34443
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
}

resource "azurerm_lb_nat_rule" "fgtbranch12mgmthttps" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = azurerm_lb.elbs_branch1.id
  name                           = "fgtbranch12-mgmt-40031"
  protocol                       = "Tcp"
  frontend_port                  = 40031
  backend_port                   = 34443
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
}

resource "azurerm_lb_nat_rule" "fgtbranch11mgmtssh" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = azurerm_lb.elbs_branch1.id
  name                           = "fgtbranch11-ssh-50030"
  protocol                       = "Tcp"
  frontend_port                  = 50030
  backend_port                   = 3422
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
}

resource "azurerm_lb_nat_rule" "fgtbranch12mgmtssh" {
  resource_group_name            = azurerm_resource_group.branchrg.name
  loadbalancer_id                = azurerm_lb.elbs_branch1.id
  name                           = "fgtbranch12-ssh-50031"
  protocol                       = "Tcp"
  frontend_port                  = 50031
  backend_port                   = 3422
  frontend_ip_configuration_name = "${var.project}-${var.TAG}-branch-${var.branchesloc[0]}-elbip"
}

//##########################Assign VM to NAT rule #######################

resource "azurerm_network_interface_nat_rule_association" "fgtbranch11mgmthttpsvm" {
  network_interface_id    = azurerm_network_interface.fgtbranch11nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgtbranch11mgmthttps.id
}

resource "azurerm_network_interface_nat_rule_association" "fgtbranch11mgmtsshvm" {
  network_interface_id    = azurerm_network_interface.fgtbranch11nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgtbranch11mgmtssh.id
}

resource "azurerm_network_interface_nat_rule_association" "fgtbranch12mgmthttpsvm" {
  network_interface_id    = azurerm_network_interface.fgtbranch12nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgtbranch12mgmthttps.id
}

resource "azurerm_network_interface_nat_rule_association" "fgtbranch12mgmtsshvm" {
  network_interface_id    = azurerm_network_interface.fgtbranch12nics.3.id
  ip_configuration_name   = "ipconfig1"
  nat_rule_id             = azurerm_lb_nat_rule.fgtbranch12mgmtssh.id
}

//############################ NIC to NSG  ############################

resource "azurerm_network_interface_security_group_association" "fgtbranch11pub" {
  network_interface_id      = azurerm_network_interface.fgtbranch11nics.0.id
  network_security_group_id = azurerm_network_security_group.branch_fgt_nsg_pub.0.id
}
resource "azurerm_network_interface_security_group_association" "fgtbranch12pub" {
  network_interface_id      = azurerm_network_interface.fgtbranch12nics.0.id
  network_security_group_id = azurerm_network_security_group.branch_fgt_nsg_pub.0.id
}

resource "azurerm_network_interface_security_group_association" "fgtbranch21pub" {
  network_interface_id      = azurerm_network_interface.fgtbranch21nics.0.id
  network_security_group_id = azurerm_network_security_group.branch_fgt_nsg_pub.1.id
}


/////////////////////////////////
resource "azurerm_network_interface_security_group_association" "fgtbranch11priv" {
  network_interface_id      = azurerm_network_interface.fgtbranch11nics.1.id
  network_security_group_id = azurerm_network_security_group.branch_fgt_nsg_priv.0.id
}
resource "azurerm_network_interface_security_group_association" "fgtbranch12priv" {
  network_interface_id      = azurerm_network_interface.fgtbranch12nics.1.id
  network_security_group_id = azurerm_network_security_group.branch_fgt_nsg_priv.0.id
}

resource "azurerm_network_interface_security_group_association" "fgtbranch21priv" {
  network_interface_id      = azurerm_network_interface.fgtbranch21nics.1.id
  network_security_group_id = azurerm_network_security_group.branch_fgt_nsg_priv.1.id
}
////////////////////////////////

resource "azurerm_network_interface_security_group_association" "fgtbranch11ha" {
  network_interface_id      = azurerm_network_interface.fgtbranch11nics.2.id
  network_security_group_id = azurerm_network_security_group.branch1_fgt_nsg_ha.id
}
resource "azurerm_network_interface_security_group_association" "fgtbranch12ha" {
  network_interface_id      = azurerm_network_interface.fgtbranch12nics.2.id
  network_security_group_id = azurerm_network_security_group.branch1_fgt_nsg_ha.id
}

/////////////////////////////////
resource "azurerm_network_interface_security_group_association" "fgtbranch11mgmt" {
  network_interface_id      = azurerm_network_interface.fgtbranch11nics.3.id
  network_security_group_id = azurerm_network_security_group.branch1_fgt_nsg_hmgmt.id
}
resource "azurerm_network_interface_security_group_association" "fgtbranch12mgmt" {
  network_interface_id      = azurerm_network_interface.fgtbranch12nics.3.id
  network_security_group_id = azurerm_network_security_group.branch1_fgt_nsg_hmgmt.id
}