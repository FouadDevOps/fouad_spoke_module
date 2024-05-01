terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  client_id       = var.sp_client_id
  client_secret   = var.sp_client_secret
  tenant_id       = var.tenant_id  # Specify the tenant ID
}
