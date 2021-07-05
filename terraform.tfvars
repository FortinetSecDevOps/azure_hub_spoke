azsubscriptionid = "useyourown"

project = "sdwan"
TAG     = "terraform"

hubsloc = ["westeurope",
]
hubscidr = ["10.10.0.0/16",
]

hub1subnetscidrs = ["10.10.1.0/24", // FGT Pub
  "10.10.2.0/24",                   // FGT Priv
  "10.10.3.0/24",                   // FGT HA
  "10.10.4.0/24"                    //  FGT MGMT
]

fgt11ip = ["10.10.1.4", // FGT Pub
  "10.10.2.4",          // FGT Priv
  "10.10.3.4",          // FGT HA
  "10.10.4.4"           //  FGT MGMT
]

fgt12ip = ["10.10.1.5", // FGT Pub
  "10.10.2.5",          // FGT Priv
  "10.10.3.5",          // FGT HA
  "10.10.4.5"           //  FGT MGMT
]

ilbip = ["10.10.2.10", // Hub1 Internal LB Listner 
]

lbprob = "3422"

fgt_vmsize       = "Standard_F8s_v2"
fgtbranch_vmsize = "Standard_D8s_v3"
lnx_vmsize       = "Standard_D2_v3"

FGT_IMAGE_SKU = "fortinet_fg-vm_payg_20190624"
FGT_VERSION   = "6.4.3"

//lnx_vmsize= "Standard_D2_v3"

username = "useyourown"
password = "useyourown"



//####################################Spoke Vnets#############################


spokesloc = ["westeurope", // spoke11
  "northeurope",           // spoke12 
]

spokescidr = ["10.11.0.0/16",
  "10.12.0.0/16",
]

spoke11subnetscidrs = ["10.11.1.0/24", // Servers1
  "10.11.2.0/24"                       // Servers2
]
spoke12subnetscidrs = ["10.12.1.0/24", // Servers1
  "10.12.2.0/24"                       // Servers2
]


//-------------------------------------------------Branch Sites----------------------------------------

branchesloc = ["westeurope", // Branch11
  "centralus",               // Branch12
]

branchescidr = ["172.16.0.0/16", // Branch11
  "172.17.0.0/16",               // Branch12
]

branch11subnetscidrs = ["172.16.1.0/24", // FGT Pub
  "172.16.2.0/24",                       // FGT Priv
  "172.16.3.0/24",                       // FGT HA
  "172.16.4.0/24"                        // FGT MGMT
]
branch21subnetscidrs = ["172.17.1.0/24", // FGT Pub
  "172.17.2.0/24",                       // FGT Priv
  "172.17.3.0/24"                        // Servers
]

fgtbranch11ip = ["172.16.1.4", // FGT Pub
  "172.16.2.4",                // FGT Priv
  "172.16.3.4",                // FGT HA
  "172.16.4.4"
]
fgtbranch12ip = ["172.16.1.5", // FGT Pub
  "172.16.2.5",                // FGT Priv
  "172.16.3.5",                // FGT HA
  "172.16.4.5"
]
fgtbranch21ip = ["172.17.1.4", // FGT Pub
  "172.17.2.4",                // FGT ISP2
  "172.17.3.4"                 // FGT Priv
]

ilbip_branch1 = ["172.16.2.10", // branch1 Internal LB Listner 
] 