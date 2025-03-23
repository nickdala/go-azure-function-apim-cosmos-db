resource "azurecaf_name" "app_workspace" {
  name          = var.environment_name
  resource_type = "azurerm_log_analytics_workspace"
}

resource "azurerm_log_analytics_workspace" "app_workspace" {
  name                = azurecaf_name.app_workspace.result
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insight
resource "azurecaf_name" "app_insights" {
  name          = var.environment_name
  resource_type = "azurerm_application_insights"
}

resource "azurerm_application_insights" "app_insights" {
  name                = azurecaf_name.app_insights.result
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.app_workspace.id
}