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

output "container_app_latest_revision_name" {
  description = "Latest revision name of the Container App"
  value       = azurerm_container_app.main.latest_revision_name
}

output "container_app_fqdn" {
  description = "Fully qualified domain name of the Container App (use for DNS CNAME)"
  value       = azurerm_container_app.main.latest_revision_fqdn
}
