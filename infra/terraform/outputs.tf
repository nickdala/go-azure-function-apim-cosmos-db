output "azure_function_name" {
  value = azurerm_linux_function_app.app.name
}

output "azure_function_url" {
  value = azurerm_linux_function_app.app.default_hostname
}

output "application_gateway_ip" {
  value = azurerm_public_ip.app_gateway_pip.ip_address
}

output "application_gateway_fqdn" {
  value = "http://${azurerm_public_ip.app_gateway_pip.ip_address}"
}