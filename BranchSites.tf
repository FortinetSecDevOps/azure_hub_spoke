//############################ Create Resource Group ##################

resource "azurerm_resource_group" "COATSBranchesRG" {
  name     = "mremini-${var.project}-${var.TAG}-Branches"
  location = "westeurope"
}

//############################ Create Branch Sites VNETs  ##################

resource "azurerm_virtual_network" "branches" {
  count = length(var.branchesloc)
  name                = "${var.project}-${var.TAG}-Spoke-${var.branchesloc[count.index]}"
  location            =  var.branchesloc[count.index]
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  address_space       = [ var.branchescidr[count.index] ]
  
  tags = {
    Project = "${var.project}"
    Role = "BranchSite"
  }
}


//############################ Create Branch Site Subnets ##################
////////////Branch11

resource "azurerm_subnet" "Branch11SUbnets" {
  count = length(var.branch11subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSBranchesRG.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name , 0)
  address_prefixes     = [ var.branch11subnetscidrs[count.index]]
}
////////////Branch12

resource "azurerm_subnet" "Branch12SUbnets" {
  count = length(var.branch12subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSBranchesRG.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name , 1)
  address_prefixes     = [ var.branch12subnetscidrs[count.index]]
}

////////////Branch21

resource "azurerm_subnet" "Branch21SUbnets" {
  count = length(var.branch21subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[2]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSBranchesRG.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name , 2)
  address_prefixes     = [ var.branch21subnetscidrs[count.index]]
}

////////////Branch22

resource "azurerm_subnet" "Branch22SUbnets" {
  count = length(var.branch22subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[4]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSBranchesRG.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name , 4)
  address_prefixes     = [ var.branch22subnetscidrs[count.index]]
}
////////////Branch31

resource "azurerm_subnet" "Branch31SUbnets" {
  count = length(var.branch31subnetscidrs)
  name                 = "${var.project}-${var.TAG}-Branch-${var.branchesloc[3]}-subnet-${count.index+1}"
  resource_group_name =  azurerm_resource_group.COATSBranchesRG.name
  virtual_network_name = element(azurerm_virtual_network.branches.*.name , 3)
  address_prefixes     = [ var.branch31subnetscidrs[count.index]]
}


//############################ Create Branch Sites FGT ##################

resource "azurerm_network_interface" "fgtbranch11nics" {
  count = length(var.fgtbranch11ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgtbranch11-port${count.index+1}"
  location                      = element(azurerm_virtual_network.branches.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  enable_ip_forwarding           = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Branch11SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgtbranch11ip[count.index]
  }

    lifecycle {
          ignore_changes = all
    }
}

resource "azurerm_network_interface" "fgtbranch12nics" {
  count = length(var.fgtbranch12ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgtbranch12-port${count.index+1}"
  location                      = element(azurerm_virtual_network.branches.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  enable_ip_forwarding           = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Branch12SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgtbranch12ip[count.index]
  }
      lifecycle {
          ignore_changes = all
    }
}

resource "azurerm_network_interface" "fgtbranch21nics" {
  count = length(var.fgtbranch21ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[2]}-fgtbranch21-port${count.index+1}"
  location                      = element(azurerm_virtual_network.branches.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  enable_ip_forwarding           = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Branch21SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgtbranch21ip[count.index]
  }

      lifecycle {
          ignore_changes = all
    }
}

resource "azurerm_network_interface" "fgtbranch22nics" {
  count = length(var.fgtbranch22ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[4]}-fgtbranch21-port${count.index+1}"
  location                      = element(azurerm_virtual_network.branches.*.location , 4)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  enable_ip_forwarding           = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Branch22SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgtbranch22ip[count.index]
  }

      lifecycle {
          ignore_changes = all
    }

}

resource "azurerm_network_interface" "fgtbranch31nics" {
  count = length(var.fgtbranch31ip)
  name                          = "${var.project}-${var.TAG}-Branch-${var.branchesloc[3]}-fgtbranch31-port${count.index+1}"
  location                      = element(azurerm_virtual_network.branches.*.location , 3)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  enable_ip_forwarding           = true
  enable_accelerated_networking   = true

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(azurerm_subnet.Branch31SUbnets.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fgtbranch31ip[count.index]
  }

      lifecycle {
          ignore_changes = all
    }
}

//############################ FGT VM ##################

data "template_file" "fgtbranch11_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = "fgtbranch11"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_ssh_public_key  = ""
    fgt_config_ha       = false
    fgt_config_autoscale = false

    Port1IP             = var.fgtbranch11ip[0]
    Port2IP             = var.fgtbranch11ip[1]

    public_subnet_mask  = cidrnetmask(var.branch11subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch11subnetscidrs[1])

    fgt_external_gw     = cidrhost(var.branch11subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.branch11subnetscidrs[1], 1)

    vnet_network        = var.branchescidr[0]
  }
}

resource "azurerm_virtual_machine" "fgtbranch11" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgt11"
  location                     = element(azurerm_virtual_network.branches.*.location , 0 )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch11nics.0.id, azurerm_network_interface.fgtbranch11nics.1.id, azurerm_network_interface.fgtbranch11nics.2.id ]
  primary_network_interface_id = element (azurerm_network_interface.fgtbranch11nics.*.id , 0)
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
    name = "${var.project}_${var.TAG}_Branch_${var.branchesloc[0]}_fgt11_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
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

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://westeuropefgtbootdiag.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

} 

///////////////////////////////////////////////////

data "template_file" "fgtbranch12_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = "fgtbranch12"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_ssh_public_key  = ""
    fgt_config_ha       = false
    fgt_config_autoscale = false

    Port1IP             = var.fgtbranch12ip[0]
    Port2IP             = var.fgtbranch12ip[1]

    public_subnet_mask  = cidrnetmask(var.branch12subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch12subnetscidrs[1])

    fgt_external_gw     = cidrhost(var.branch12subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.branch12subnetscidrs[1], 1)

    vnet_network        = var.branchescidr[1]
  }
}

resource "azurerm_virtual_machine" "fgtbranch12" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgt12"
  location                     = element(azurerm_virtual_network.branches.*.location , 1 )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch12nics.0.id, azurerm_network_interface.fgtbranch12nics.1.id, azurerm_network_interface.fgtbranch12nics.2.id ]
  primary_network_interface_id = element (azurerm_network_interface.fgtbranch12nics.*.id , 0)
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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[1]}_fgt12_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Branch_${var.branchesloc[1]}_fgt12_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[1]}-fgt12"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch12_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://northeuropefgtbootdiag.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

}


///////////////////////////////////////////////////

data "template_file" "fgtbranch21_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = "fgtbranch21"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_ssh_public_key  = ""
    fgt_config_ha       = false
    fgt_config_autoscale = false

    Port1IP             = var.fgtbranch21ip[0]
    Port2IP             = var.fgtbranch21ip[1]

    public_subnet_mask  = cidrnetmask(var.branch21subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch21subnetscidrs[1])

    fgt_external_gw     = cidrhost(var.branch21subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.branch21subnetscidrs[1], 1)

    vnet_network        = var.branchescidr[2]
  }
}

resource "azurerm_virtual_machine" "fgtbranch21" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[2]}-fgt21"
  location                     = element(azurerm_virtual_network.branches.*.location , 2 )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch21nics.0.id, azurerm_network_interface.fgtbranch21nics.1.id, azurerm_network_interface.fgtbranch21nics.2.id ]
  primary_network_interface_id = element (azurerm_network_interface.fgtbranch21nics.*.id , 0)
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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[2]}_fgt21_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Branch_${var.branchesloc[2]}_fgt21_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[2]}-fgt21"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch21_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://eastusfgtbootdiag.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

}

///////////////////////////////////////////////////

data "template_file" "fgtbranch22_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = "fgtbranch22"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_ssh_public_key  = ""
    fgt_config_ha       = false
    fgt_config_autoscale = false

    Port1IP             = var.fgtbranch22ip[0]
    Port2IP             = var.fgtbranch22ip[1]

    public_subnet_mask  = cidrnetmask(var.branch22subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch22subnetscidrs[1])

    fgt_external_gw     = cidrhost(var.branch22subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.branch22subnetscidrs[1], 1)

    vnet_network        = var.branchescidr[3]
  }
}

resource "azurerm_virtual_machine" "fgtbranch22" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[4]}-fgt22"
  location                     = element(azurerm_virtual_network.branches.*.location , 4 )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch22nics.0.id, azurerm_network_interface.fgtbranch22nics.1.id, azurerm_network_interface.fgtbranch22nics.2.id ]
  primary_network_interface_id = element (azurerm_network_interface.fgtbranch22nics.*.id , 0)
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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[4]}_fgt22_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Branch_${var.branchesloc[4]}_fgt22_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[4]}-fgt22"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch22_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://westusfgtbootdiag.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

}


///////////////////////////////////////////////////

data "template_file" "fgtbranch31_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = "fgtbranch31"
    fgt_license_file    = ""
    fgt_username        = var.username
    fgt_ssh_public_key  = ""
    fgt_config_ha       = false
    fgt_config_autoscale = false

    Port1IP             = var.fgtbranch31ip[0]
    Port2IP             = var.fgtbranch31ip[1]

    public_subnet_mask  = cidrnetmask(var.branch31subnetscidrs[0])
    private_subnet_mask = cidrnetmask(var.branch31subnetscidrs[1])

    fgt_external_gw     = cidrhost(var.branch31subnetscidrs[0], 1)
    fgt_internal_gw     = cidrhost(var.branch31subnetscidrs[1], 1)

    vnet_network        = var.branchescidr[3]
  }
}

resource "azurerm_virtual_machine" "fgtbranch31" {
  name                         = "${var.project}-${var.TAG}-Branch-${var.branchesloc[3]}-fgt31"
  location                     = element(azurerm_virtual_network.branches.*.location , 3 )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_interface_ids        = [azurerm_network_interface.fgtbranch31nics.0.id, azurerm_network_interface.fgtbranch31nics.1.id , azurerm_network_interface.fgtbranch31nics.2.id ]
  primary_network_interface_id = element (azurerm_network_interface.fgtbranch31nics.*.id , 0)
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
    name              = "${var.project}_${var.TAG}_Branch_${var.branchesloc[3]}_fgt31_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_Branch_${var.branchesloc[3]}_fgt31_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "10"
  }
  os_profile {
    computer_name  = "${var.project}-${var.TAG}-Branch-${var.branchesloc[3]}-fgt31"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgtbranch31_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://southeastasiafgtbootdiag.blob.core.windows.net/"
  }

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

}



//############################ Create FGT NSG ##################

resource "azurerm_network_security_group" "branch_fgt_nsg_pub" {
  count = length(var.branchesloc)
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[count.index]}-pub-nsg"
  location                      = element(azurerm_virtual_network.branches.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
}

  
resource "azurerm_network_security_rule" "branch_fgt_nsg_pub_egress" {
  count = length(var.branchesloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
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
resource "azurerm_network_security_rule" "branch_fgt_nsg_pub_ingress_1" {
  count = length(var.branchesloc)
  name                        = "AllInbound"
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
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
  count = length(var.branchesloc)
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[count.index]}-priv-nsg"
  location                      = element(azurerm_virtual_network.branches.*.location , count.index )
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
}

  resource "azurerm_network_security_rule" "branch_fgt_nsg_priv_egress" {
  count = length(var.branchesloc)
  name                        = "AllOutbound"
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
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
resource "azurerm_network_security_rule" "branch_fgt_nsg_priv_ingress_1" {
  count = length(var.branchesloc)
  name                        = "TCP_ALL"
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_priv.*.name , count.index )
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "172.16.0.0/12"
  destination_address_prefix  = "*"
  
} 
resource "azurerm_network_security_rule" "branch_fgt_nsg_priv_ingress_2" {
  count = length(var.hubsloc)
  name                        = "UDP_ALL"
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name
  network_security_group_name = element(azurerm_network_security_group.branch_fgt_nsg_priv.*.name , count.index )
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "172.16.0.0/12"
  destination_address_prefix  = "*"
  
} 


//////////////////

resource "azurerm_public_ip" "fgtbranch11pip" {
  count               = 2
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[0]}-fgt11pip-${count.index +1}"
  location            = element(azurerm_virtual_network.branches.*.location , 0 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
/*
resource "azurerm_public_ip" "fgtbranch12pip" {
  count               = 2
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[count.index]}-fgt12pip-${count.index +1}"
  location            = element(azurerm_virtual_network.branches.*.location , 1 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
} */

resource "azurerm_public_ip" "fgtbranch21pip" {
  count               = 2
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[2]}-fgt21pip-${count.index +1}"
  location            = element(azurerm_virtual_network.branches.*.location , 2 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "fgtbranch22pip" {
  count               = 2
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[4]}-fgt22pip-${count.index +1}"
  location            = element(azurerm_virtual_network.branches.*.location , 4 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "fgtbranch31pip" {
  count               = 2
  name                = "${var.project}-${var.TAG}-Branch-${var.branchesloc[3]}-fgt31pip-${count.index +1}"
  location            = element(azurerm_virtual_network.branches.*.location , 3 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


//############################ Create Pivate Route Tables ##################

resource "azurerm_route_table" "Branch11privRTB" {
  name                          = "${var.project}-${var.TAG}-branch11-priv_RTB"
  location            = element(azurerm_virtual_network.branches.*.location , 0 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Branch11privRTB_assoc" {
  subnet_id      = element(azurerm_subnet.Branch11SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.Branch11privRTB.id
}

resource "azurerm_route" "Branch11priv_default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  route_table_name    = azurerm_route_table.Branch11privRTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.fgtbranch11ip[2]
}

///////////////////////////////

resource "azurerm_route_table" "Branch12privRTB" {
  name                          = "${var.project}-${var.TAG}-branch12-priv_RTB"
  location            = element(azurerm_virtual_network.branches.*.location , 1 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Branch12privRTB_assoc" {
  subnet_id      = element(azurerm_subnet.Branch12SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.Branch12privRTB.id
}

resource "azurerm_route" "Branch12priv_default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  route_table_name    = azurerm_route_table.Branch12privRTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.fgtbranch12ip[2]
}


///////////////////////////////

resource "azurerm_route_table" "Branch21privRTB" {
  name                          = "${var.project}-${var.TAG}-branch21-priv_RTB"
  location            = element(azurerm_virtual_network.branches.*.location , 2 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Branch21privRTB_assoc" {
  subnet_id      = element(azurerm_subnet.Branch21SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.Branch21privRTB.id
}

resource "azurerm_route" "Branch21priv_default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  route_table_name    = azurerm_route_table.Branch21privRTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.fgtbranch21ip[2]
}



///////////////////////////////

resource "azurerm_route_table" "Branch22privRTB" {
  name                          = "${var.project}-${var.TAG}-branch22-priv_RTB"
  location            = element(azurerm_virtual_network.branches.*.location , 4 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Branch22privRTB_assoc" {
  subnet_id      = element(azurerm_subnet.Branch22SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.Branch22privRTB.id
}


resource "azurerm_route" "Branch22priv_default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  route_table_name    = azurerm_route_table.Branch22privRTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.fgtbranch22ip[2]
}



///////////////////////////////

resource "azurerm_route_table" "Branch31privRTB" {
  name                          = "${var.project}-${var.TAG}-branch31-priv_RTB"
  location            = element(azurerm_virtual_network.branches.*.location , 3 )
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

resource "azurerm_subnet_route_table_association" "Branch31privRTB_assoc" {
  subnet_id      = element(azurerm_subnet.Branch31SUbnets.*.id , 2)
  route_table_id = azurerm_route_table.Branch31privRTB.id
}

resource "azurerm_route" "Branch31priv_default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.COATSBranchesRG.name
  route_table_name    = azurerm_route_table.Branch31privRTB.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.fgtbranch31ip[2]
}



//############################ Create Linux VMs inside Branch Sites ##################

data "template_file" "branch_lnx_customdata" {
  template = "./assets/lnx-spoke.tpl"

  vars = {
  }
}


///////////////////LNX Branch11

resource "azurerm_network_interface" "branch11lnxnic" {
  name                          = "${var.project}-${var.TAG}-Branch11-${var.branchesloc[0]}-lnx-port1"
  location                      = element(azurerm_virtual_network.branches.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch11SUbnets.*.id, 2)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "branch11lnx" {
  name                  = "branch11lnx"
  location                      = element(azurerm_virtual_network.branches.*.location , 0)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  network_interface_ids = [azurerm_network_interface.branch11lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "branch11lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "branch11lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.branch_lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "Branch11"
  }

}

///////////////////LNX Branch12

resource "azurerm_network_interface" "branch12lnxnic" {
  name                          = "${var.project}-${var.TAG}-Branch12-${var.branchesloc[1]}-lnx-port1"
  location                      = element(azurerm_virtual_network.branches.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch12SUbnets.*.id, 2)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "branch12lnx" {
  name                          = "branch12lnx"
  location                      = element(azurerm_virtual_network.branches.*.location , 1)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  network_interface_ids = [azurerm_network_interface.branch12lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "branch12lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "branch12lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.branch_lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "Branch12"
  }

}

///////////////////LNX Branch21

resource "azurerm_network_interface" "branch21lnxnic" {
  name                          = "${var.project}-${var.TAG}-Branch21-${var.branchesloc[2]}-lnx-port1"
  location                      = element(azurerm_virtual_network.branches.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch21SUbnets.*.id, 2)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "branch21lnx" {
  name                          = "branch21lnx"
  location                      = element(azurerm_virtual_network.branches.*.location , 2)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  network_interface_ids = [azurerm_network_interface.branch21lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "branch21lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "branch21lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.branch_lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "Branch21"
  }

}

///////////////////LNX Branch31

resource "azurerm_network_interface" "branch31lnxnic" {
  name                          = "${var.project}-${var.TAG}-Branch31-${var.branchesloc[3]}-lnx-port1"
  location                      = element(azurerm_virtual_network.branches.*.location , 3)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch31SUbnets.*.id, 2)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "branch31lnx" {
  name                          = "branch31lnx"
  location                      = element(azurerm_virtual_network.branches.*.location , 3)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  network_interface_ids = [azurerm_network_interface.branch31lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "branch31lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "branch31lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.branch_lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "Branch31"
  }

}


///////////////////LNX Branch22

resource "azurerm_network_interface" "branch22lnxnic" {
  name                          = "${var.project}-${var.TAG}-Branch22-${var.branchesloc[4]}-lnx-port1"
  location                      = element(azurerm_virtual_network.branches.*.location , 4)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  enable_ip_forwarding            = false
  enable_accelerated_networking   = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Branch22SUbnets.*.id, 2)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "branch22lnx" {
  name                          = "branch22lnx"
  location                      = element(azurerm_virtual_network.branches.*.location , 4)
  resource_group_name           = azurerm_resource_group.COATSBranchesRG.name

  network_interface_ids = [azurerm_network_interface.branch22lnxnic.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "branch22lnx-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "branch22lnx"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.branch_lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.project}"
    Role = "Branch22"
  }

}