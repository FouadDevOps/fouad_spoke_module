
resource "azurerm_storage_account" "sa" {
  name                     = "fouadazurestorage"
  resource_group_name      = "aks_resource_group"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [ azurerm_resource_group.aks_rg ]
  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "sc" {
  name                  = "tfstate-container"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
  depends_on = [ azurerm_storage_account.sa ]
}


# terraform {
#   backend "azurerm" {
#     resource_group_name = "aks_resource_group"
#     storage_account_name = "fouadazurestorage"
#     container_name = "tfstate-container"
#     key = "terraform.tfstate"
#   }
# }