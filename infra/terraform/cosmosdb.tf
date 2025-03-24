# ------------------------------------------------------------------------------------------------------
# Deploy cosmos db account
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "db_account_name" {
  name          = var.environment_name
  resource_type = "azurerm_cosmosdb_account"
}

resource "azurerm_cosmosdb_account" "db" {
  name                            = azurecaf_name.db_account_name.result
  location                        = azurerm_resource_group.resource_group.location
  resource_group_name             = azurerm_resource_group.resource_group.name
  offer_type                      = "Standard"
  kind                            = "MongoDB"
  mongo_server_version            = "4.2"

  capabilities {
    name = "EnableServerless"
  }

  lifecycle {
    ignore_changes = [capabilities]
  }
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.resource_group.location
    failover_priority = 0
    zone_redundant    = false
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy cosmos mongo db and collections
# ------------------------------------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  name                = "todosdb"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
}

resource "azurerm_cosmosdb_mongo_collection" "list" {
  name                = "todos"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  shard_key           = "_id"


  index {
    keys   = ["_id"]
  }
}