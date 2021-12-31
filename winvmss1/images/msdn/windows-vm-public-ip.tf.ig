resource "azurerm_public_ip" "winvmss1_msdn" {
  count                   = var.allow_access_via_public_ip ? 1 : 0
  name                    = "${lower(local.windows_vm_name)}-publicip"
  resource_group_name     = azurerm_resource_group.winvmss1_msdn.name
  location                = azurerm_resource_group.winvmss1_msdn.location
  allocation_method       = "Static"
  sku                     = "Basic"
  ip_version              = "IPv4"
  idle_timeout_in_minutes = "4"
  domain_name_label       = null
  reverse_fqdn            = null
  tags                    = var.tags
}
