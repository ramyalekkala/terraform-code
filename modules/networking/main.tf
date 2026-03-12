resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  address_space       = var.vnet_cidr
}

# Integration Subnet
resource "azurerm_subnet" "integration_subnet" {
  name                 = var.subnet1_name
  resource_group_name  = data.terraform_remote_state.rg.outputs.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet1_cidr
}
#application subnet
resource"azurerm_subnet" "app-subnet" {
  name = var.app_subnet_name
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.app_subnet_cidr
}

# Private Endpoint Subnet
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = var.subnet2_name
  resource_group_name  = data.terraform_remote_state.rg.outputs.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet2_cidr
}

data "terraform_remote_state" "rg" {
  backend = "local"

  config = {
    path = "../rg/terraform.tfstate"
  }
}
