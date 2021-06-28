variable "TAG" {
    description = "Customer Prefix TAG of the created ressources"
    type= string
} 

variable "project" {
    description = "project Prefix TAG of the created ressources"
    type= string
}

variable "azsubscriptionid"{
description = "Azure Subscription id"
}

//--------------------------------

variable "hubsloc" {
    description = "Hubs Location"
    type = list(string)

}
variable "hubscidr" {
    description = "Hubs CIDRs"
    type = list(string)

}

//---------------Hubs Subnets--------
variable "hub1subnetscidrs" {
    description = "Hub1 Subnets CIDRs"
    type = list(string)

}

variable "hub2subnetscidrs" {
    description = "Hub2 Subnets CIDRs"
    type = list(string)

}
variable "hub3subnetscidrs" {
    description = "Hub3 Subnets CIDRs"
    type = list(string)

}


//--------------------------------
variable "fgt_vmsize" {
  description = "FGT VM size"
}
variable "fgtbranch_vmsize" {
  description = "FGT Branch VM size"
}
variable "lnx_vmsize" {
  description = "Linux VM size"
}

variable "FGT_IMAGE_SKU" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
}
variable "FGT_VERSION" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}
//------------------------------

variable "username" {
}
variable "password" {
}

//-------------------------------------------------FGTs Hub----------------------------------------

//-------------------Hub1----------
variable "fgt11ip" {
    description = "FGT11 nics IP"
    type = list(string)

}
variable "fgt12ip" {
    description = "FGT11 nics IP"
    type = list(string)

}

//-------------------Hub2----------
variable "fgt21ip" {
    description = "FGT21 nics IP"
    type = list(string)

}
variable "fgt22ip" {
    description = "FGT21 nics IP"
    type = list(string)

}

//-------------------Hub3----------
variable "fgt31ip" {
    description = "FGT21 nics IP"
    type = list(string)

}
variable "fgt32ip" {
    description = "FGT21 nics IP"
    type = list(string)

}

//-------------------Internal LB Listner----------
variable "ilbip" {
    description = "Internal LBs IP"
    type = list(string)
}
variable "lbprob" {
    description = "Internal LBs Port Probing"
}



//---------------Spoke VNETs--------

variable "spokesloc" {
    description = "Spoke VNETs Location"
    type = list(string)

}
variable "spokescidr" {
    description = "Spokes Subnets CIDRs"
    type = list(string)

}

//---------------Spoke VNETs Subnets--------
variable "spoke11subnetscidrs" {
    description = "Spoke 11 Subnets CIDRs"
    type = list(string)
}
variable "spoke12subnetscidrs" {
    description = "Spoke 12 Subnets CIDRs"
    type = list(string)
}
variable "spoke21subnetscidrs" {
    description = "Spoke 21 Subnets CIDRs"
    type = list(string)
}
variable "spoke22subnetscidrs" {
    description = "Spoke 22 Subnets CIDRs"
    type = list(string)
}
variable "spoke31subnetscidrs" {
    description = "Spoke 31 Subnets CIDRs"
    type = list(string)
}
variable "spoke32subnetscidrs" {
    description = "Spoke 32 Subnets CIDRs"
    type = list(string)
}


//---------------Branch Site VNETs--------

variable "branchesloc" {
    description = "Spoke VNETs Location"
    type = list(string)

}
variable "branchescidr" {
    description = "Branch Sites  CIDRs"
    type = list(string)

}

//---------------Branch Site VNETs Subnets--------
variable "branch11subnetscidrs" {
    description = "Spoke 11 Subnets CIDRs"
    type = list(string)
}
variable "branch12subnetscidrs" {
    description = "Spoke 12 Subnets CIDRs"
    type = list(string)
}
variable "branch21subnetscidrs" {
    description = "Spoke 21 Subnets CIDRs"
    type = list(string)
}
variable "branch22subnetscidrs" {
    description = "Spoke 21 Subnets CIDRs"
    type = list(string)
}

variable "branch31subnetscidrs" {
    description = "Spoke 31 Subnets CIDRs"
    type = list(string)
}



//-------------------------------------------------FGTs Branches----------------------------------------

variable "fgtbranch11ip" {
    description = "FGT Branch11 nics IP"
    type = list(string)

}
variable "fgtbranch12ip" {
    description = "FGT Branch12 nics IP"
    type = list(string)
}

variable "fgtbranch21ip" {
    description = "FGT Branch21 nics IP"
    type = list(string)

}
variable "fgtbranch22ip" {
    description = "FGT Branch21 nics IP"
    type = list(string)

}
variable "fgtbranch31ip" {
    description = "FGT Branch31 nics IP"
    type = list(string)
}



