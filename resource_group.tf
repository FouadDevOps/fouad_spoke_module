resource "azurerm_resource_group" "aks_rg" {
  name     = "aks_resource_group"
  location = "East US"
}

data "azurerm_resource_group" "aks_rg" {
  name                 = "aks_resource_group"

}

output "rg_id" {
  value = data.azurerm_resource_group.aks_rg
}