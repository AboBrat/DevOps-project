# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.28.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id ="891195e4-c78e-4b5d-86b4-88b6d1875195"
  tenant_id = "4d229559-cbcf-4d33-b775-b508748825c0"
  features {
    
  }

}
#Import existing RG
resource "azurerm_resource_group" "rg" {
  name = "RES-GRP-CT360-TUTORING-ADV-F5B6F"
  location = "West Europe"
  
  lifecycle {
    prevent_destroy = true
  }
}