provider "azurerm" {
  features {}
  
}

##################
# Resource Group #
##################

resource "azurerm_resource_group" "hub-rg" {
  name     = "hub-rg"
  location = var.azure_location

}

resource "azurerm_resource_group" "spoke-rg" {
  name     = "spoke-rg"
  location = var.azure_location
}

