resource "azurerm_resource_group" "aks_rg" {
  name     = "aks_resource_group"
  location = "East US"
}


output "aks_rg_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "aks_rg_location" {
  value = azurerm_resource_group.aks_rg.location
}