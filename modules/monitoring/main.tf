resource "azurerm_resource_group" "myrg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "mylog-workspace" {
  name                = var.log_space_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}