variable "az_TAG" {
  description = "Customer Prefix TAG of the created ressources"
  type        = string
}

variable "az_project" {
  description = "project Prefix TAG of the created ressources"
  type        = string
}

variable "azsubscriptionid" {
  description = "Azure Subscription id"
}

//---------------Hubs -----------------

variable "az_hubsloc" {
  description = "Hubs Location"
  type        = list(string)

}
variable "az_hubscidr" {
  description = "Hubs CIDRs"
  type        = list(string)

}

//---------------Hubs Subnets--------
variable "az_hub1subnetscidrs" {
  description = "Hub1 Subnets CIDRs"
  type        = list(string)

}

//-------------------Hub1 NICs----------
variable "az_fgt11ip" {
  description = "FGT11 nics IP"
  type        = list(string)

}
variable "az_fgt12ip" {
  description = "FGT11 nics IP"
  type        = list(string)

}

variable "az_ilbip" {
  description = "Internal LBs IP"
  type        = list(string)
}
variable "az_lbprob" {
  description = "Internal LBs Port Probing"
}



//-----------------FG information ---------------
variable "az_fgt_vmsize" {
  description = "FGT VM size"
}
variable "az_fgtbranch_vmsize" {
  description = "FGT Branch VM size"
}
variable "az_lnx_vmsize" {
  description = "Linux VM size"
}

variable "az_FGT_IMAGE_SKU" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
}
variable "az_FGT_VERSION" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}
//------------------------------

variable "az_username" {
}
variable "az_password" {
}


//---------------Spoke VNETs--------

variable "az_spokesloc" {
  description = "Spoke VNETs Location"
  type        = list(string)

}
variable "az_spokescidr" {
  description = "Spokes Subnets CIDRs"
  type        = list(string)

}

//---------------Spoke VNETs Subnets--------
variable "az_spoke11subnetscidrs" {
  description = "Spoke 11 Subnets CIDRs"
  type        = list(string)
}
variable "az_spoke12subnetscidrs" {
  description = "Spoke 12 Subnets CIDRs"
  type        = list(string)
}

//---------------Branch Site VNETs--------

variable "az_branchesloc" {
  description = "Spoke VNETs Location"
  type        = list(string)

}
variable "az_branchescidr" {
  description = "Branch Sites  CIDRs"
  type        = list(string)

}

//---------------Branch Site VNETs Subnets--------
variable "az_branch11subnetscidrs" {
  description = "Spoke 11 Subnets CIDRs"
  type        = list(string)
}

variable "az_branch21subnetscidrs" {
  description = "Spoke 21 Subnets CIDRs"
  type        = list(string)
}

variable "az_fgtbranch11ip" {
  description = "FGT Branch11 nics IP"
  type        = list(string)

}
variable "az_fgtbranch12ip" {
  description = "FGT Branch12 nics IP"
  type        = list(string)
}

variable "az_fgtbranch21ip" {
  description = "FGT Branch21 nics IP"
  type        = list(string)

}

variable "az_ilbip_branch1" {
  description = "Internal LBs IP"
  type        = list(string)
}