azsubscriptionid = "Use your own" 

project = "sdwan"
TAG = "option1"

hubsloc = ["westeurope", 
            "eastus", 
            "southeastasia"
        ]
hubscidr = ["10.10.0.0/16", 
            "10.20.0.0/16", 
            "10.30.0.0/16"
        ] 

hub1subnetscidrs = ["10.10.1.0/24",    // FGT Pub
                    "10.10.2.0/24",    // FGT Priv
                    "10.10.3.0/24",    // FGT HA
                    "10.10.4.0/24"    //  FGT MGMT
                ]
hub2subnetscidrs = ["10.20.1.0/24",    // FGT Pub
                    "10.20.2.0/24",    // FGT Priv
                    "10.20.3.0/24",    // FGT HA
                    "10.20.4.0/24"    //  FGT MGMT
                ]
hub3subnetscidrs = ["10.30.1.0/24",    // FGT Pub
                    "10.30.2.0/24",    // FGT Priv
                    "10.30.3.0/24",    // FGT HA
                    "10.30.4.0/24"    //  FGT MGMT
                ]                                   

//-------------------------------------------------FGTs----------------------------------------
fgt11ip         =  ["10.10.1.4",    // FGT Pub
                    "10.10.2.4",    // FGT Priv
                    "10.10.3.4",    // FGT HA
                    "10.10.4.4"    //  FGT MGMT
                ]

fgt12ip         =  ["10.10.1.5",    // FGT Pub
                    "10.10.2.5",    // FGT Priv
                    "10.10.3.5",    // FGT HA
                    "10.10.4.5"    //  FGT MGMT
                ]

fgt21ip         =  ["10.20.1.4",    // FGT Pub
                    "10.20.2.4",    // FGT Priv
                    "10.20.3.4",    // FGT HA
                    "10.20.4.4"    //  FGT MGMT
                ]

fgt22ip         =  ["10.20.1.5",    // FGT Pub
                    "10.20.2.5",    // FGT Priv
                    "10.20.3.5",    // FGT HA
                    "10.20.4.5"    //  FGT MGMT
                ]

fgt31ip         =  ["10.30.1.4",    // FGT Pub
                    "10.30.2.4",    // FGT Priv
                    "10.30.3.4",    // FGT HA
                    "10.30.4.4"    //  FGT MGMT
                ]

fgt32ip         =  ["10.30.1.5",    // FGT Pub
                    "10.30.2.5",    // FGT Priv
                    "10.30.3.5",    // FGT HA
                    "10.30.4.5"    //  FGT MGMT
                ]
                

ilbip           =  ["10.10.2.10",    // Hub1 Internal LB Listner 
                    "10.20.2.10",    // Hub2 Internal LB Listner
                    "10.30.2.10",    // Hub3 Internal LB Listner
                ] 
lbprob =        "3422"                                                    

fgt_vmsize = "Standard_F8s_v2"
fgtbranch_vmsize = "Standard_D8s_v3"
lnx_vmsize= "Standard_D2_v3"

FGT_IMAGE_SKU= "fortinet_fg-vm_payg_20190624"
FGT_VERSION = "6.4.3"

//lnx_vmsize= "Standard_D2_v3"

username = "UseyourOwn"
password =  "Useyourown"


//-------------------------------------------------Spoke VNETs----------------------------------------

spokesloc = ["westeurope",              // spoke11
             "northeurope",             // spoke12 
             "eastus",                  // spoke21 
             "westus",                  // spoke22
             "southeastasia",           // spoke31
             "eastasia"                 // spoke32
            ]

spokescidr = [  "10.11.0.0/16",
                "10.12.0.0/16",
                "10.21.0.0/16", 
                "10.22.0.0/16",
                "10.31.0.0/16", 
                "10.32.0.0/16"                
            ] 

spoke11subnetscidrs = [ "10.11.1.0/24",    // Servers1
                        "10.11.2.0/24"     // Servers2
                    ] 
spoke12subnetscidrs = [ "10.12.1.0/24",    // Servers1
                        "10.12.2.0/24"     // Servers2
                    ]                        

spoke21subnetscidrs = [ "10.21.1.0/24",    // Servers1
                        "10.21.2.0/24"     // Servers2
                    ] 
spoke22subnetscidrs = [ "10.22.1.0/24",    // Servers1
                        "10.22.2.0/24"     // Servers2
                    ] 

spoke31subnetscidrs = [ "10.31.1.0/24",    // Servers1
                        "10.31.2.0/24"     // Servers2
                    ] 
spoke32subnetscidrs = [ "10.32.1.0/24",    // Servers1
                        "10.32.2.0/24"     // Servers2
                    ]                     
//-------------------------------------------------Branch Sites----------------------------------------

branchesloc = ["westeurope",   // Branch11
             "northeurope",    // Branch12
             "eastus",          // Branch21
             "southeastasia",   // Branch31
              "westus"            // Branch22
            ]

branchescidr = ["172.16.0.0/16",  // Branch11
                "172.17.0.0/16",  // Branch12
                "172.20.0.0/16",  // Branch21
                "172.30.0.0/16",  // Branch31
                "172.21.0.0/16"   // Branch22
        ] 

branch11subnetscidrs = ["172.16.1.0/24",    // FGT Pub
                        "172.16.2.0/24",    // FGT Priv
                        "172.16.3.0/24"     // Servers
                ]
branch12subnetscidrs = ["172.17.1.0/24",    // FGT Pub
                        "172.17.2.0/24",    // FGT Priv
                        "172.17.3.0/24"     // Servers
                ]                

branch21subnetscidrs = ["172.20.1.0/24",    // FGT Pub
                        "172.20.2.0/24",    // FGT Priv
                        "172.20.3.0/24"     // Servers
                 ]

branch22subnetscidrs = ["172.21.1.0/24",    // FGT Pub
                        "172.21.2.0/24",    // FGT Priv
                        "172.21.3.0/24"     // Servers

                ]  

branch31subnetscidrs = ["172.30.1.0/24",    // FGT Pub
                        "172.30.2.0/24",    // FGT Priv
                        "172.30.3.0/24"     // Servers

                ]

                 

fgtbranch11ip   =  ["172.16.1.4",     // FGT ISP1
                    "172.16.2.4",     // FGT ISP2
                    "172.16.3.4"      // FGT Priv
                ]
fgtbranch12ip   =  ["172.17.1.4",     // FGT ISP1
                    "172.17.2.4",     // FGT ISP2
                    "172.17.3.4"      // FGT Priv
                ]
fgtbranch21ip   =  ["172.20.1.4",      // FGT ISP1
                    "172.20.2.4",      // FGT ISP2
                    "172.20.3.4"       // FGT Priv
                ]

fgtbranch22ip   =  ["172.21.1.4",    // FGT ISP1
                    "172.21.2.4",    // FGT ISP2
                    "172.21.3.4"     // FGT Priv
                ]  

fgtbranch31ip   =  ["172.30.1.4",    // FGT ISP1
                    "172.30.2.4",    // FGT ISP2
                    "172.30.3.4"     // FGT Priv
                ] 

