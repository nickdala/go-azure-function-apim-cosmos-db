resource "azurerm_key_vault_secret" "key_vault_secret_mongo_connection_string" {
  name         = "mongo-connection-string"
  value        = azurerm_cosmosdb_account.db.primary_mongodb_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [ azurerm_role_assignment.current_user_role_assignement ]
}