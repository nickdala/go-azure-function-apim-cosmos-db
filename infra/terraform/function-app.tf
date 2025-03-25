resource "random_pet" "app" {
}

resource "azurerm_linux_function_app" "app" {
  name                = "blogfunction-${random_pet.app.id}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    cors {
        allowed_origins = ["https://portal.azure.com", "https://ms.portal.azure.com"]
    }
    
    vnet_route_all_enabled = true
  }
  
  virtual_network_subnet_id = azurerm_subnet.function_app_subnet.id
  
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "custom"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsStorage"      = azurerm_storage_account.example.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
    "WEBSITE_VNET_ROUTE_ALL" = "1"

    // key vault reference to secret
    "MONGODB_URI" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.key_vault.vault_uri}secrets/${azurerm_key_vault_secret.key_vault_secret_mongo_connection_string.name}/${azurerm_key_vault_secret.key_vault_secret_mongo_connection_string.version})"
  }
}