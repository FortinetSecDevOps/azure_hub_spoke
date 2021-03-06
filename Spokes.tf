//############################ Create Spoke VNETs  ##################

resource "azurerm_virtual_network" "Spokes" {
  count               = length(var.az_spokesloc)
  name                = "${var.az_project}-${var.az_TAG}-Spoke-${var.az_spokesloc[count.index]}"
  location            = var.az_spokesloc[count.index]
  resource_group_name = azurerm_resource_group.hubrg.name
  address_space       = [var.az_spokescidr[count.index]]

  tags = {
    Project = "${var.az_project}"
    Role    = "SpokeVNET"
  }
}

//############################ Create Spoke Subnets and UDR ##################
////////////Spoke11

resource "azurerm_subnet" "Spoke11SUbnets" {
  count                = length(var.az_spoke11subnetscidrs)
  name                 = "${var.az_project}-${var.az_TAG}-Spoke-${var.az_spokesloc[0]}-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name, 0)
  address_prefixes     = [var.az_spoke11subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke11privRTB" {
  name                = "${var.az_project}-${var.az_TAG}-Spoke11_RTB"
  location            = var.az_spokesloc[0]
  resource_group_name = azurerm_resource_group.hubrg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.az_project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke11privRTB_assoc" {
  count          = length(var.az_spoke11subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke11SUbnets.*.id, count.index)
  route_table_id = azurerm_route_table.Spoke11privRTB.id
}

resource "azurerm_route" "Spoke11privRTB_to_br11" {
  name                   = "branch11"
  resource_group_name    = azurerm_resource_group.hubrg.name
  route_table_name       = azurerm_route_table.Spoke11privRTB.name
  address_prefix         = "172.16.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.az_ilbip[0]
}
resource "azurerm_route" "Spoke11privRTB_to_br12" {
  name                   = "branch12"
  resource_group_name    = azurerm_resource_group.hubrg.name
  route_table_name       = azurerm_route_table.Spoke11privRTB.name
  address_prefix         = "172.17.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.az_ilbip[0]
}

////////////Spoke12

resource "azurerm_subnet" "Spoke12SUbnets" {
  count                = length(var.az_spoke12subnetscidrs)
  name                 = "${var.az_project}-${var.az_TAG}-Spoke-${var.az_spokesloc[1]}-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.hubrg.name
  virtual_network_name = element(azurerm_virtual_network.Spokes.*.name, 1)
  address_prefixes     = [var.az_spoke12subnetscidrs[count.index]]
}

resource "azurerm_route_table" "Spoke12privRTB" {
  name                = "${var.az_project}-${var.az_TAG}-Spoke12_RTB"
  location            = var.az_spokesloc[1]
  resource_group_name = azurerm_resource_group.hubrg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.az_project}"
  }
}

resource "azurerm_subnet_route_table_association" "Spoke12privRTB_assoc" {
  count          = length(var.az_spoke12subnetscidrs)
  subnet_id      = element(azurerm_subnet.Spoke12SUbnets.*.id, count.index)
  route_table_id = azurerm_route_table.Spoke12privRTB.id
}

resource "azurerm_route" "Spoke12privRTB_to_br11" {
  name                   = "branch11"
  resource_group_name    = azurerm_resource_group.hubrg.name
  route_table_name       = azurerm_route_table.Spoke12privRTB.name
  address_prefix         = "172.16.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.az_ilbip[0]
}
resource "azurerm_route" "Spoke12privRTB_to_br12" {
  name                   = "branch12"
  resource_group_name    = azurerm_resource_group.hubrg.name
  route_table_name       = azurerm_route_table.Spoke12privRTB.name
  address_prefix         = "172.17.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.az_ilbip[0]
}

//############################ Create Linux VMs inside Spokes ##################

data "template_file" "lnx_customdata" {
  template = "./assets/lnx-spoke.tpl"

  vars = {
  }
}


///////////////////LNX Spoke11

resource "azurerm_network_interface" "spoke11lnxnic" {
  name                = "${var.az_project}-${var.az_TAG}-Spoke11-${var.az_spokesloc[0]}-lnx-port1"
  location            = element(azurerm_virtual_network.Spokes.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name

  enable_ip_forwarding          = false
  enable_accelerated_networking = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke11SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke11lnx" {
  name                = "spoke11lnx"
  location            = element(azurerm_virtual_network.Spokes.*.location, 0)
  resource_group_name = azurerm_resource_group.hubrg.name

  network_interface_ids = [azurerm_network_interface.spoke11lnxnic.id]
  vm_size               = var.az_lnx_vmsize

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
    admin_username = var.az_username
    admin_password = var.az_password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.az_project}"
    Role    = "LNX11"
  }

}

///////////////////LNX Spoke12

resource "azurerm_network_interface" "spoke12lnxnic" {
  name                = "${var.az_project}-${var.az_TAG}-Spoke12-${var.az_spokesloc[1]}-lnx-port1"
  location            = element(azurerm_virtual_network.Spokes.*.location, 1)
  resource_group_name = azurerm_resource_group.hubrg.name

  enable_ip_forwarding          = false
  enable_accelerated_networking = false
  //network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = element(azurerm_subnet.Spoke12SUbnets.*.id, 0)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke12lnx" {
  name                = "spoke12lnx"
  location            = element(azurerm_virtual_network.Spokes.*.location, 1)
  resource_group_name = azurerm_resource_group.hubrg.name

  network_interface_ids = [azurerm_network_interface.spoke12lnxnic.id]
  vm_size               = var.az_lnx_vmsize

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
    admin_username = var.az_username
    admin_password = var.az_password
    custom_data    = data.template_file.lnx_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    Project = "${var.az_project}"
    Role    = "LNX12"
  }

}



