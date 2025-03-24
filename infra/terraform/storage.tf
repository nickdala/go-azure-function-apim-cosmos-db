resource "azurecaf_name" "app_storage" {
  name          = var.environment_name
  resource_type = "azurerm_storage_account"
}

resource "azurerm_storage_account" "example" {
  name                     = azurecaf_name.app_storage.result
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}