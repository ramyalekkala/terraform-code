output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet1_name" {
  value = azurerm_subnet.integration_subnet.name
}
output "subnet2_name" {
  value = azurerm_subnet.private_endpoint_subnet.name
  
}
output "integration_subnet_id" {
  value = azurerm_subnet.integration_subnet.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoint_subnet.id
}
output "app_subnet_id" {
   value = azurerm_subnet.app_subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id

}

output "vnet_cidr" {
   value = azurerm_virtual_network.vnet.address_space
}
output "subnet1_cidr" {
   value = azurerm_subnet.integration_subnet.address_prefixes
}
output "subnet2_cidr" {
   value = azurerm_private_endpoint_subnet.address_prefixes
}

