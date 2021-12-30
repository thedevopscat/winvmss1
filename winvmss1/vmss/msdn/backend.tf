terraform {
  backend "azurerm" {
    key                  = "winvmss1-msdn-vmss.terraform.tfstate"
    storage_account_name = "dkiacmsdnstor"
    container_name       = "dk-iac-msdn-stor-blob"
  }
}
