data "azurerm_client_config" "current_config" {}

data "http" "mycurrentexternalipaddress" {
  url = "http://whatismyip.akamai.com"
}

data "azurerm_virtual_network" "dk_network_msdn_vnet" {
  name                = "dk-network-msdn-weu-vnet"
  resource_group_name = "dk-network-msdn-weu-rg"
}

data "azurerm_subnet" "dk_network_msdn_app_subnet" {
  name                 = "dk-network-msdn-weu-app-subnet"
  virtual_network_name = data.azurerm_virtual_network.dk_network_msdn_vnet.name
  resource_group_name  = data.azurerm_virtual_network.dk_network_msdn_vnet.resource_group_name
}

# data "azurerm_storage_account" "vm_diags_storage_account" {
#   name                = data.azurerm_storage_account.iac_storage_account.name
#   resource_group_name = data.azurerm_storage_account.iac_storage_account.resource_group_name
# }

data "azurerm_storage_account" "iac_storage_account" {
  name                = "dkiacmsdnstor"
  resource_group_name = "dk-iac-msdn-weu-rg"
}

data "azurerm_key_vault" "iac_key_vault" {
  name                = "dk-iac-msdn-kv"
  resource_group_name = "dk-iac-msdn-weu-rg"
}

data "azurerm_key_vault_secret" "admin_username" {
  name         = "VM-ACCOUNT"
  key_vault_id = data.azurerm_key_vault.iac_key_vault.id
}

data "azurerm_key_vault_secret" "admin_password" {
  name         = "VM-PASSWORD"
  key_vault_id = data.azurerm_key_vault.iac_key_vault.id
}
