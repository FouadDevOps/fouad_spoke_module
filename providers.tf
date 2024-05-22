
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.102.0"
    }
  }
}

provider "azurerm" {
    features {}

  client_id       = "9b47d401-29f3-443d-9db1-1c0aff07dedd"
  client_secret   = var.client_secret
  tenant_id       = "744200ba-c436-41f9-bed1-1f0ca4be3d41"
  subscription_id = "6d8f5795-12dd-4f05-82f3-47e1830275c7"
}