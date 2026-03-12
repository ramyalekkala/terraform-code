resource "azurerm_virtual_network" "vnet" {
  name                = data.terraform_remote_state.vnet.outputs.vnet_name
  address_space       = data.terraform_remote_state.vnet.outputs.vnet_cidr
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = data.terraform_remote_state.rg.outputs.rg_name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.vnet_name
  address_prefixes     = data.terraform_remote_state.integration_subnet.outputs.subnet_cidr
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networking.outputs.integration_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name
  location            = data.terraform_remote_state.rg.outputs.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
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
