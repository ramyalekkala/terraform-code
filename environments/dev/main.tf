module "rg" {
  source = "../../modules/rg"
   rg_name  = var.rg_name
  location = var.location
}

module "network" {
  source = "../../modules/networking"
  vnet_name = var.vnet_name
  vnet_cidr = var.vnet_cidr
  subnet1_name = var.subnet1_name
  subnet1_cidr = var.subnet1_cidr
  subnet2_name = var.subnet2_name
  subnet2_cidr = var.subnet2_cidr
  app_subnet_name = var.app_subnet_name
  app_subnet_cidr = var.app_subnet_cidr
}

module "vm" {
  source = "../../modules/vm"
  vm_name = var.vm_name
}
module "sql" {
    source = "../../modules/keyvault"
    vault_name = var.vault_name
    sql_admin_password = var.sql_admin_password
    
}
module "aks" {
  source = "../../modules/aks"
  aks_cluster_name = var.aks_cluster_name
}
module "database" {
  source = "../../modules/database"
  sqlserver_name = var.sqlserver_name
  database_name = var.database_name
}