output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "container_app_environment_name" {
  description = "Name of the Container Apps environment"
  value       = azurerm_container_app_environment.main.name
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.main.name
}

output "container_app_fqdn" {
  description = "Container App FQDN (target for the app's custom-domain CNAME records)"
  value       = "${azurerm_container_app.main.name}.${azurerm_container_app_environment.main.default_domain}"
}