output "azure_function_name" {
  value = azurerm_linux_function_app.app.name
}

output "azure_function_url" {
  value = azurerm_linux_function_app.app.default_hostname
}