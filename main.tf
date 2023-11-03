module "network" {
  source = "./network"  # Chemin vers le module réseau

  resource_group_name = var.resource_group_name
  resource_group_location = var.resource_group_location
  vnet = var.vnet
  address_space = var.address_space
  subnet = var.subnet
  addresse_subnet = var.addresse_subnet
}



resource   "azurerm_public_ip"   "pubip"   { 
   name   =   "pip1" 
   location   =   module.network.resource_group_location
   resource_group_name   =   module.network.resource_group_name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 } 

resource   "azurerm_network_interface"   "nic"   { 
   name   =   "vm1nic" 
   location   = module.network.resource_group_location
   resource_group_name   =   module.network.resource_group_name

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   module.network.subnet
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.pubip.id 
   } 
 } 

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "linuxVM"
  location            = module.network.resource_group_location
  resource_group_name = module.network.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                = "Standard_DS2_v2" # Replace with your desired VM size
  admin_username      = "david"  # Replace with your desired admin username
  admin_ssh_key {
    username   = "david"       # Replace with your desired admin username
    public_key = file("~/.ssh/id2_rsa.pub") # Replace with the path to your SSH public key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_8"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i azure_rm.yml playbook.yml"
    working_dir = "/mnt/c/Users/utilisateur/Documents/Brief13"
  }
}
