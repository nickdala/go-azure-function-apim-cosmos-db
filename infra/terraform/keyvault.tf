resource "azurecaf_name" "key_vault" {
  random_length = "15"
  resource_type = "azurerm_key_vault"
}

resource "azurerm_key_vault" "key_vault" {
  name                = azurecaf_name.key_vault.result
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  tenant_id                  = data.azuread_client_config.current.tenant_id
  soft_delete_retention_days = 7

  enable_rbac_authorization = true

  sku_name = "standard"
}

resource azurerm_role_assignment current_user_role_assignement {
  scope                 = azurerm_key_vault.key_vault.id
  role_definition_name  = "Key Vault Administrator"
  principal_id          = data.azuread_client_config.current.object_id
}

# Give the app access to the key vault secrets - https://learn.microsoft.com/azure/key-vault/general/rbac-guide?tabs=azure-cli#secret-scope-role-assignment
resource azurerm_role_assignment app_keyvault_role_assignment {
  scope                 = azurerm_key_vault.key_vault.id
  role_definition_name  = "Key Vault Secrets User"
  principal_id          = azurerm_linux_function_app.example.identity[0].principal_id
}