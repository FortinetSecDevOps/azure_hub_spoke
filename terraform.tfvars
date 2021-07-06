azsubscriptionid = "useyourown"

az_project = "sdwan"
az_TAG     = "terraform"

az_hubsloc = ["westeurope",
]
az_hubscidr = ["10.10.0.0/16",
]

az_hub1subnetscidrs = ["10.10.1.0/24", // FGT Pub
  "10.10.2.0/24",                   // FGT Priv
  "10.10.3.0/24",                   // FGT HA
  "10.10.4.0/24"                    //  FGT MGMT
]

az_fgt11ip = ["10.10.1.4", // FGT Pub
  "10.10.2.4",          // FGT Priv
  "10.10.3.4",          // FGT HA
  "10.10.4.4"           //  FGT MGMT
]

az_fgt12ip = ["10.10.1.5", // FGT Pub
  "10.10.2.5",          // FGT Priv
  "10.10.3.5",          // FGT HA
  "10.10.4.5"           //  FGT MGMT
]

az_ilbip = ["10.10.2.10", // Hub1 Internal LB Listner 
]

az_lbprob = "3422"

az_fgt_vmsize       = "Standard_F8s_v2"
az_fgtbranch_vmsize = "Standard_D8s_v3"
az_lnx_vmsize       = "Standard_D2_v3"

az_FGT_IMAGE_SKU = "fortinet_fg-vm_payg_20190624"
az_FGT_VERSION   = "6.4.3"

//lnx_vmsize= "Standard_D2_v3"

az_username = "useyourown"
az_password = "useyourown"



//####################################Spoke Vnets#############################


az_spokesloc = ["westeurope", // spoke11
  "northeurope",           // spoke12 
]

az_spokescidr = ["10.11.0.0/16",
  "10.12.0.0/16",
]

az_spoke11subnetscidrs = ["10.11.1.0/24", // Servers1
  "10.11.2.0/24"                       // Servers2
]
az_spoke12subnetscidrs = ["10.12.1.0/24", // Servers1
  "10.12.2.0/24"                       // Servers2
]


//-------------------------------------------------Branch Sites----------------------------------------

az_branchesloc = ["westeurope", // Branch11
  "centralus",               // Branch12
]

az_branchescidr = ["172.16.0.0/16", // Branch11
  "172.17.0.0/16",               // Branch12
]

az_branch11subnetscidrs = ["172.16.1.0/24", // FGT Pub
  "172.16.2.0/24",                       // FGT Priv
  "172.16.3.0/24",                       // FGT HA
  "172.16.4.0/24"                        // FGT MGMT
]
az_branch21subnetscidrs = ["172.17.1.0/24", // FGT Pub
  "172.17.2.0/24",                       // FGT Priv
  "172.17.3.0/24"                        // Servers
]

az_fgtbranch11ip = ["172.16.1.4", // FGT Pub
  "172.16.2.4",                // FGT Priv
  "172.16.3.4",                // FGT HA
  "172.16.4.4"
]
az_fgtbranch12ip = ["172.16.1.5", // FGT Pub
  "172.16.2.5",                // FGT Priv
  "172.16.3.5",                // FGT HA
  "172.16.4.5"
]
az_fgtbranch21ip = ["172.17.1.4", // FGT Pub
  "172.17.2.4",                // FGT ISP2
  "172.17.3.4"                 // FGT Priv
]

az_ilbip_branch1 = ["172.16.2.10", // branch1 Internal LB Listner 
] 