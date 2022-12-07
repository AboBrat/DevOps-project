resource "azurerm_public_ip" "pubip" {
  count = 2
  name                = "PublicIp${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}