resource "azurecaf_name" "vnet" {
  name          = var.environment_name
  resource_type = "azurerm_virtual_network"
}

resource "azurerm_virtual_network" "vnet" {
  name                = azurecaf_name.vnet.result
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "function_app_subnet" {
  name                 = "function-app-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  
  delegation {
    name = "function-app-delegation"
    
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}