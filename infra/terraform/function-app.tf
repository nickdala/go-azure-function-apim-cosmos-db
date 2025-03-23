resource "azurerm_linux_function_app" "example" {
  name                = "bloggapifunction-go"
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
  }
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "custom"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsStorage"      = azurerm_storage_account.example.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key

    // key vault reference to secret
    "MONGODB_URI" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.key_vault.vault_uri}secrets/${azurerm_key_vault_secret.key_vault_secret_mongo_connection_string.name}/${azurerm_key_vault_secret.key_vault_secret_mongo_connection_string.version})"
  }

}