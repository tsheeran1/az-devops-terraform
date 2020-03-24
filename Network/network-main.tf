# Define Terraform provider
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    resource_group_name   = "tsheeran-tfstate-rg"
    storage_account_name  = "tsheeran685631be5a22a33"
    container_name        = "core-tfstate"
    key                   = "network-example.tfstate"
  }
}
# Configure the Azure provider
provider "azurerm" { 
    version     = "~>2.0"
    features {}
    environment = "public"
}
# Create a resource group for network
resource "azurerm_resource_group" "network-rg" {
  name = "${var.app_name}-${var.environment}-rg"
  location = var.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}
# Create the network VNET
resource "azurerm_virtual_network" "network-vnet" {
  name = "${var.app_name}-${var.environment}-vnet"
  address_space = [var.network-vnet-cidr]
  resource_group_name = azurerm_resource_group.network-rg.name
  location = azurerm_resource_group.network-rg.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}
# Create a subnet for Network
resource "azurerm_subnet" "network-subnet" {
  name = "${var.app_name}-${var.environment}-subnet"
  address_prefix = var.network-subnet-cidr
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name = azurerm_resource_group.network-rg.name
}