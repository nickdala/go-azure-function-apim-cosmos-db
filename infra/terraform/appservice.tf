resource "azurecaf_name" "app_service_plan" {
  name          = var.environment_name
  resource_type = "azurerm_app_service_plan"
}


resource "azurerm_service_plan" "example" {
  name                = azurecaf_name.app_service_plan.result
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Linux"
  sku_name            = "EP1"
}