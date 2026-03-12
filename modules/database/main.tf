
data "terraform_remote_state" "rg" {
  backend = "local"

  config = {
    path = "../rg/terraform.tfstate"
  }
}

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../networking/terraform.tfstate"
  }
}
data "terraform_remote_state" "keyvault" {
  backend = "local"

  config = {
    path = "../keyvault/terraform.tfstate"
  }
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.terraform_remote_state.keyvault.outputs.keyvault_id
}



#########################################
 #SQL SERVER CREATION
#########################################
resource "azurerm_mssql_server" "sqlserver" {
  name                         = var.sqlserver_name
  resource_group_name          = data.terraform_remote_state.rg.outputs.rg_name
  location                     = data.terraform_remote_state.rg.outputs.location
  version                      = "12.0"

  administrator_login          = "sqladmin"
  administrator_login_password = data.terraform_remote_state.keyvault.outputs.sql_admin_password

  public_network_access_enabled = false
}
#########################################
#SQL DATABASE
#########################################
resource "azurerm_mssql_database" "database" {
    name = var.database_name
    server_id = azurerm_mssql_server.sqlserver.id
    sku_name = "Basic"
}
##########################################
#PRIVATE ENDPOINT INTEGRATION
##########################################
resource "azurerm_private_endpoint" "sql_pe" {
    name= "sql-private-endpoint"
    location = data.terraform_remote_state.rg.outputs.location
    resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
    subnet_id = data.terraform_remote_state.networking.outputs.private_endpoint_subnet_id

    private_service_connection {
      name = "sql-service-connection"
      private_connection_resource_id = azurerm_mssql_server.sqlserver.id
      subresource_names = [ "sqlServer" ]
      is_manual_connection = false
    }

}
##########################################
#PRIVATE DNS ZONE
#########################################
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
}
########################################
#LINK DNS TO VIRTUAL NETWORK
########################################
resource "azurerm_private_dns_zone_virtual_network_link" "myzonelink" {
  name                  = "dns-link-vnet"
  resource_group_name   = data.terraform_remote_state.rg.outputs.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = data.terraform_remote_state.networking.outputs.vnet_id
}
