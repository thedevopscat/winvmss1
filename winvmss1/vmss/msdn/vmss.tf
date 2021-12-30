# Create A Network Security Group (NSG) That Will Be Applied To VMSS's Network Interface (NIC)
resource "azurerm_network_security_group" "winvmss1_msdn" {
  name                = lower(join("-", [var.company_code, substr(var.tags["service"], 0, 10), substr(var.tags["environment"], 0, 7), lookup(var.region_code, var.location), "nsg"]))
  resource_group_name = azurerm_resource_group.winvmss1_msdn.name
  location            = azurerm_resource_group.winvmss1_msdn.location
  tags                = var.tags
}

# Create NSG Rule To Allow All Inbound Traffic Originating From The Azure Load Balancer Service (Default Azure NSG Rule Required Here Due To Denying East/West Traffic)
resource "azurerm_network_security_rule" "winvmss1_msdn_allow_azureloadbalancer" {
  name                                       = "allow-all-azureloadbalancer"
  resource_group_name                        = azurerm_resource_group.winvmss1_msdn.name
  network_security_group_name                = azurerm_network_security_group.winvmss1_msdn.name
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

# Create NSG Rule To Deny East/West Traffic Within The Subnet
resource "azurerm_network_security_rule" "winvmss1_msdn_deny_east_west" {
  name                                       = "deny-all-inbound"
  resource_group_name                        = azurerm_resource_group.winvmss1_msdn.name
  network_security_group_name                = azurerm_network_security_group.winvmss1_msdn.name
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

resource "azurerm_windows_virtual_machine_scale_set" "winvmss1_msdn" {
  name                   = "dk-winvmss1-msdn-weu-vmss"
  location               = azurerm_resource_group.winvmss1_msdn.location
  resource_group_name    = azurerm_resource_group.winvmss1_msdn.name
  admin_username         = data.azurerm_key_vault_secret.admin_username.value
  admin_password         = data.azurerm_key_vault_secret.admin_password.value
  upgrade_mode           = "Manual"
  single_placement_group = true
  overprovision          = false
  zones                  = []
  # https://docs.microsoft.com/en-us/azure/virtual-machines/dv3-dsv3-series
  sku             = "Standard_D8s_v3" # Supports Ephemeral OS Disks Which Are Recommended For Scale Sets To Improve Virtual Machine Reimage Times
  instances       = 1                 # This Will Get Set To 0 By Azure DevOps But Setting To 1 Means The First Agent Is Visible In The Azure DevOps Portal
  source_image_id = data.azurerm_image.winvmss1.id
  os_disk {
    caching                   = "ReadOnly"
    storage_account_type      = "Standard_LRS"
    write_accelerator_enabled = false
    diff_disk_settings {
      option = "Local" # Ephemeral Disk
    }
  }
  encryption_at_host_enabled = false
  computer_name_prefix       = "winvmss1" # max 9 chars...
  boot_diagnostics {
    storage_account_uri = null # Managed Storage Account
  }
  license_type = "Windows_Server"
  network_interface {
    dns_servers                   = null
    enable_accelerated_networking = true
    enable_ip_forwarding          = false
    name                          = "dk-network-msdn-weu-vnet-nic01"
    network_security_group_id     = azurerm_network_security_group.winvmss1_msdn.id
    primary                       = true
    ip_configuration {
      name      = "IPConfiguration"
      subnet_id = data.azurerm_subnet.dk_network_msdn_app_subnet.id
      primary   = true
    }
  }
  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags, instances, extension
    ]
  }
  # checkov:skip=CKV_AZURE_97:Encryption At Host Not Mandatory
}
