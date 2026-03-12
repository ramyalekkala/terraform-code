output "keyvault_id" {
  value = azurerm_key_vault.myvault.id
}

output "keyvault_name" {
  value = azurerm_key_vault.myvault.name
}

output "sql_admin_password" {
  value     = azurerm_key_vault_secret.sql_admin_password.value
  sensitive = true
}
output "sql_admin_password_secret_id" {
  value = azurerm_key_vault_secret.sql_admin_password.id
}


