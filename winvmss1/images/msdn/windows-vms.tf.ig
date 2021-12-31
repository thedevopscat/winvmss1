locals {
  windows_vm_name = "dk-winvmss1-vm"
  dns_suffix      = "stwater.intra"
}

# Create NSG Applied To VM's NIC
resource "azurerm_network_security_group" "winvmss1_msdn_windows_vm_nsg" {
  name                = join("-", [lower(var.company_code), replace((lower(var.tags["service"])), " ", "-"), "imagevm", replace((lower(var.tags["environment"])), " ", "-"), "nsg"])
  resource_group_name = azurerm_resource_group.winvmss1_msdn.name
  location            = azurerm_resource_group.winvmss1_msdn.location
  tags                = var.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_security_rule" "winvmss1_msdn_windows_vm_nsg_rule_allow_azureloadbalancer" {
  name                                       = "allow-all-azureloadbalancer"
  resource_group_name                        = azurerm_resource_group.winvmss1_msdn.name
  network_security_group_name                = azurerm_network_security_group.winvmss1_msdn_windows_vm_nsg.name
  description                                = "Allows all inbound traffic originating from the Azure Load Balancer service. Default Azure NSG rule."
  protocol                                   = "*"
  source_port_range                          = "*"
  destination_port_range                     = "*"
  source_address_prefix                      = "AzureLoadBalancer"
  source_application_security_group_ids      = null
  destination_address_prefix                 = "VirtualNetwork"
  destination_application_security_group_ids = null
  access                                     = "Allow"
  priority                                   = "1120"
  direction                                  = "Inbound"
}

# Create NSG Rule To Allow RDP Traffic From The Virtual Network To The VM
resource "azurerm_network_security_rule" "winvmss1_msdn_windows_vm_nsg_rule_allow_rdp" {
  name                                       = "allow-tcp3389-rdp"
  resource_group_name                        = azurerm_resource_group.winvmss1_msdn.name
  network_security_group_name                = azurerm_network_security_group.winvmss1_msdn_windows_vm_nsg.name
  description                                = "Allows RDP traffic inbound from STW IP addresses"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "3389"
  source_address_prefix                      = join("", [data.http.mycurrentexternalipaddress.body, "/32"])
  source_application_security_group_ids      = null
  destination_address_prefix                 = "VirtualNetwork"
  destination_application_security_group_ids = null
  access                                     = "Allow"
  priority                                   = "1130"
  direction                                  = "Inbound"
}

/* resource "azurerm_network_security_rule" "winvmss1_msdn_windows_vm_nsg_rule_allow_smb" {
  
  name                                       = "allow-any445-smb"
  resource_group_name                        = azurerm_resource_group.winvmss1_msdn.name
  network_security_group_name                = azurerm_network_security_group.winvmss1_msdn_windows_vm_nsg.name
  description                                = "Allows SMB, for CIFS etc"
  protocol                                   = "*"
  source_port_range                          = "*"
  destination_port_range                     = "445"
  source_address_prefix                      = "VirtualNetwork"
  source_application_security_group_ids      = null
  destination_address_prefix                 = "VirtualNetwork"
  destination_application_security_group_ids = null
  access                                     = "Allow"
  priority                                   = "1140"
  direction                                  = "Inbound"
} */

# Create NSG Rule To Deny East/West Traffic Within The Subnet
resource "azurerm_network_security_rule" "winvmss1_msdn_windows_vm_nsg_rule_deny_east_west" {

  name                                       = "deny-all-inbound"
  resource_group_name                        = azurerm_resource_group.winvmss1_msdn.name
  network_security_group_name                = azurerm_network_security_group.winvmss1_msdn_windows_vm_nsg.name
  description                                = "Denies ALL traffic inbound providing East/West protection"
  protocol                                   = "*"
  source_port_range                          = "*"
  destination_port_range                     = "*"
  source_address_prefix                      = "*"
  source_application_security_group_ids      = null
  destination_address_prefix                 = "*"
  destination_application_security_group_ids = null
  access                                     = "Deny"
  priority                                   = "4095"
  direction                                  = "Inbound"
}

resource "azurerm_network_interface" "winvmss1_msdn_windows_vm_nic" {
  name                          = "${lower(local.windows_vm_name)}-eth0-nic"
  resource_group_name           = azurerm_resource_group.winvmss1_msdn.name
  location                      = azurerm_resource_group.winvmss1_msdn.location
  internal_dns_name_label       = lower(local.windows_vm_name) # optional - this is a name not a dns suffix or fqdn...
  enable_ip_forwarding          = false                        # optional
  enable_accelerated_networking = false                        # optional: not supported on all sku's including all burstables/b series.
  dns_servers                   = null                         # optional, added on the vnet...
  ip_configuration {
    name                          = "${lower(local.windows_vm_name)}-ip"
    subnet_id                     = data.azurerm_subnet.dk_network_msdn_app_subnet.id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Dynamic"
    # private_ip_address          = null
    public_ip_address_id = var.allow_access_via_public_ip ? azurerm_public_ip.winvmss1_msdn[0].id : null
    primary              = true
  }
  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
  #checkov:skip=CKV_AZURE_119:Public IP Permitted For Testing
}

resource "azurerm_network_interface_security_group_association" "winvmss1_msdn_windows_vm_nsg_association" {
  network_interface_id      = azurerm_network_interface.winvmss1_msdn_windows_vm_nic.id
  network_security_group_id = azurerm_network_security_group.winvmss1_msdn_windows_vm_nsg.id
}

resource "azurerm_windows_virtual_machine" "winvmss1_msdn_windows_vm" {
  name                  = lower(local.windows_vm_name)
  resource_group_name   = azurerm_resource_group.winvmss1_msdn.name
  location              = azurerm_resource_group.winvmss1_msdn.location
  network_interface_ids = [azurerm_network_interface.winvmss1_msdn_windows_vm_nic.id]
  size                  = "Standard_D2s_v3" # "Standard_D8s_v4"
  admin_username        = data.azurerm_key_vault_secret.admin_username.value
  admin_password        = data.azurerm_key_vault_secret.admin_password.value
  os_disk {
    name                 = "${lower(local.windows_vm_name)}-osdisk"
    caching              = "ReadWrite" # Default for Windows OS disks
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "50"
  }
  #Optional Arguments start here
  availability_set_id = null
  # boot_diagnostics {
  #   storage_account_uri = data.azurerm_storage_account.vm_diags_storage_account.primary_blob_endpoint
  # }
  enable_automatic_updates = true
  # Specifies the type of on-premise license (aka Azure Hybrid Use Benefit). Possible values: None, Windows_Client and Windows_Server. 
  # Changing this forces a new resource to be created (as per help page): https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html
  license_type = "None"
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest"
  }
  provision_vm_agent = true
  timezone           = "GMT Standard Time"
  tags               = var.tags
  lifecycle {
    ignore_changes = [
      tags, license_type, os_disk,
    ]
  }
  depends_on = [azurerm_network_interface_security_group_association.winvmss1_msdn_windows_vm_nsg_association]
  #checkov:skip=CKV_AZURE_50:vm extentions enabled warning added 28/11/21
}

resource "azurerm_virtual_machine_extension" "stw_wrapper" {
  name                       = "CustomScriptExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.winvmss1_msdn_windows_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings                   = null
  lifecycle {
    ignore_changes = [
      settings,
    ]
  }
  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${azurerm_storage_account.winvmss1_msdn.name}",
      "storageAccountKey": "${azurerm_storage_account.winvmss1_msdn.primary_access_key}",
      "fileUris": [
        "${azurerm_storage_blob.scripts_toolset_2019.url}",
        "${azurerm_storage_blob.scripts_configure_antivirus_ps1.url}",
        "${azurerm_storage_blob.scripts_install_powershellmodules_ps1.url}",
        "${azurerm_storage_blob.scripts_initialize_vm.url}",
        "${azurerm_storage_blob.scripts_install_vs_ps1.url}",
        "${azurerm_storage_blob.stw_wrapper_ps1.url}",
        "${azurerm_storage_blob.run_once_ps1.url}",
        "${azurerm_storage_blob.image_helpers_chocohelpers_ps1.url}",
        "${azurerm_storage_blob.image_helpers_imagehelpers_psd1.url}",
        "${azurerm_storage_blob.image_helpers_imagehelpers_psm1.url}",
        "${azurerm_storage_blob.image_helpers_installhelpers_ps1.url}",
        "${azurerm_storage_blob.image_helpers_pathhelpers_ps1.url}",
        "${azurerm_storage_blob.image_helpers_testshelpers_ps1.url}",
        "${azurerm_storage_blob.image_helpers_visualstudiohelpers_ps1.url}",
        "${azurerm_storage_blob.image_helpers_test_imagehelpers_tests_ps1.url}",
        "${azurerm_storage_blob.image_helpers_test_pathhelpers_tests_ps1.url}",
        "${azurerm_storage_blob.tests_powershellmodules_tests_ps1.url}",
        "${azurerm_storage_blob.tests_visualstudio_tests_ps1.url}"
        ],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ./scripts/stw-wrapper.ps1"
    }
PROTECTED_SETTINGS
  tags               = var.tags
  depends_on = [
    azurerm_windows_virtual_machine.winvmss1_msdn_windows_vm,
  ]
  timeouts {
    create = "55m"
    delete = "55m"
  }
}
