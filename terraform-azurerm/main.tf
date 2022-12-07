
#Create network
resource "azurerm_virtual_network" "vnet" {
  name                = "F5B6F-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
#Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#Create interface
resource "azurerm_network_interface" "nic" {
  count = 2
  name                = "F5B6F-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id = azurerm_public_ip.pubip[count.index].id
  }
}

 resource "azurerm_managed_disk" "amd" {
   count                = 2
   name                 = "datadisk_existing_${count.index}"
   location             = azurerm_resource_group.rg.location
   resource_group_name  = azurerm_resource_group.rg.name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
 }

resource "azurerm_network_security_group" "nsg" {
  name                = "VM-Security-Group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  }

resource "azurerm_network_security_rule" "rules" {
  for_each                    = local.nsgrules 
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_availability_set" "avset" {
   name                         = "avset"
   location                     = azurerm_resource_group.rg.location
   resource_group_name          = azurerm_resource_group.rg.name
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }
  
#Create Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  count = 2
  name                = "vm-machine${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}