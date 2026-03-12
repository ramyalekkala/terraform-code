############################################
# Read Resource Group from remote state
############################################

data "terraform_remote_state" "rg" {
  backend = "local"

  config = {
    path = "../rg/terraform.tfstate"
  }
}

############################################
# Read Networking resources from remote state
############################################

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../networking/terraform.tfstate"
  }
}

############################################
#READ DATABASE RESOURCE FROM REMOTE STATE
############################################
data "terraform_remote_state" "database" {
  backend = "local"

  config = {
    path = "../database/terraform.tfstate"
  }
}

data "terraform_remote_state" "keyvault" {
  backend = "local"
  
  config = {
     path = "../keyvault/terraform.tfstate"
  }
}



############################################
# App Service Plan
############################################

resource "azurerm_service_plan" "plan" {
  name                = "appservice-plan"
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  os_type             = "Linux"
  sku_name            = "B1"
}

############################################
# Application Insights
############################################

resource "azurerm_application_insights" "appinsights" {
  name                = "demo-appinsights"
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  application_type    = "web"
}

############################################
# App Service
############################################

resource "azurerm_linux_web_app" "webapp" {
  name                = "demo-webapp"
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  service_plan_id     = azurerm_service_plan.plan.id
  identity {
    type = "SystemAssigned"
  }

  site_config {}

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.appinsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appinsights.connection_string
    SQL_PASSWORD = "@Microsoft.KeyVault(SecretUri=${data.terraform_remote_state.keyvault.outputs.sql_admin_password_secret_id})"

  }
}

############################################
# VNet Integration
############################################

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = data.terraform_remote_state.networking.outputs.integration_subnet_id
}

############################################
# Private Endpoint (example for SQL)
############################################

resource "azurerm_private_endpoint" "pe" {
  name                = "appservice-private-endpoint"
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  subnet_id           = data.terraform_remote_state.networking.outputs.private_endpoint_subnet_id

  private_service_connection {
    name                           = "sql-private-connection"
    private_connection_resource_id = data.terraform_remote_state.database.outputs.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}
