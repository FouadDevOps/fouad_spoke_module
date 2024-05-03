resource "azurerm_resource_group" "aks_rg" {
  name     = "aks_resource_group"
  location = "eastus"
}