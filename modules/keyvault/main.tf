
# It tells terraform that fetch the current logged details-from the azure account
data "azurerm_client_config" "current" {}

############################################
# Read Resource Group from remote state
############################################

data "terraform_remote_state" "rg" {
  backend = "local"

  config = {
    path = "../rg/terraform.tfstate"
  }
}

resource "azurerm_key_vault" "myvault" {
  name                        = var.vault_name
  location                    = data.terraform_remote_state.rg.outputs.location
  resource_group_name         = data.terraform_remote_state.rg.outputs.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "List",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.myvault.id
}
