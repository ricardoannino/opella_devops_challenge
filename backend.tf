terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "opellatfstate"
    container_name       = "tfstate"
  }
}