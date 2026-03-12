resource "azurerm_storage_account" "sc" {
  name                     = var.storage_account_name
  resource_group_name      = data.terraform_remote_state.rg.outputs.rg_name
  location                 = data.terraform_remote_state.rg.outputs.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}


# Private DNS Zone
resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
}

# DNS Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "storage-dns-link"
  resource_group_name   = data.terraform_remote_state.rg.outputs.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = data.terraform_remote_state.network.outputs.vnet_id
}

# Private Endpoint
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-storage-dev"
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  subnet_id           = data.terraform_remote_state.networking.outputs.private_endpoint_subnet_id

  private_service_connection {
    name                           = "storage-private-connection"
    private_connection_resource_id = azurerm_storage_account.sc.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
   private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns.id]
  }
}

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
