resource "azurerm_storage_account" "winvmss1_msdn" {
  name                      = lower(replace(join("", [var.company_code, substr(var.tags["service"], 0, 10), var.tags["environment"], "stor1"]), " ", ""))
  resource_group_name       = azurerm_resource_group.winvmss1_msdn.name
  location                  = azurerm_resource_group.winvmss1_msdn.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  tags                      = var.tags
  #checkov:skip=CKV_AZURE_33:queue service not in use by default, remove this if queues are to be used.
  #checkov:skip=CKV_AZURE_35:this would be handled via azurerm_storage_account_network_rules
  #checkov:skip=CKV_AZURE_43:the storage account name is created dynamically, this checks it is < 24 characters
  #checkov:skip=CKV2_AZURE_1:customer managed keys are not part of our company strategy
  #checkov:skip=CKV2_AZURE_8:this would be handled via azurerm_storage_container
  #checkov:skip=CKV2_AZURE_18:customer managed keys are not part of our company strategy
}

resource "azurerm_storage_container" "winvmss1_msdn" {
  name                  = lower(join("-", [var.company_code, substr(var.tags["service"], 0, 10), substr(var.tags["environment"], 0, 7), "stor-blob"]))
  storage_account_name  = azurerm_storage_account.winvmss1_msdn.name
  container_access_type = "private"
  #checkov:skip=CKV2_AZURE_21
}

resource "azurerm_storage_blob" "scripts_toolset_2019" {
  name                   = "scripts/toolset-2019.json"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/toolset-2019.json"
}

resource "azurerm_storage_blob" "scripts_configure_antivirus_ps1" {
  name                   = "scripts/Configure-Antivirus.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/Configure-Antivirus.ps1"
}

resource "azurerm_storage_blob" "scripts_install_powershellmodules_ps1" {
  name                   = "scripts/Install-PowerShellModules.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/Install-PowerShellModules.ps1"
}

resource "azurerm_storage_blob" "scripts_initialize_vm" {
  name                   = "scripts/Initialize-VM.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/Initialize-VM.ps1"
}

resource "azurerm_storage_blob" "scripts_install_vs_ps1" {
  name                   = "scripts/Install-VS.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/Install-VS.ps1"
}

resource "azurerm_storage_blob" "run_once_ps1" {
  name                   = "scripts/run-once.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/run-once.ps1"
}

resource "azurerm_storage_blob" "stw_wrapper_ps1" {
  name                   = "scripts/stw-wrapper.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/stw-wrapper.ps1"
  depends_on = [
    null_resource.add_credentials_to_stw_wapper
  ]
}

resource "azurerm_storage_blob" "image_helpers_chocohelpers_ps1" {
  name                   = "scripts/ImageHelpers/ChocoHelpers.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/ChocoHelpers.ps1"
}

resource "azurerm_storage_blob" "image_helpers_imagehelpers_psd1" {
  name                   = "scripts/ImageHelpers/ImageHelpers.psd1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/ImageHelpers.psd1"
}

resource "azurerm_storage_blob" "image_helpers_imagehelpers_psm1" {
  name                   = "scripts/ImageHelpers/ImageHelpers.psm1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/ImageHelpers.psm1"
}

resource "azurerm_storage_blob" "image_helpers_installhelpers_ps1" {
  name                   = "scripts/ImageHelpers/InstallHelpers.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/InstallHelpers.ps1"
}

resource "azurerm_storage_blob" "image_helpers_pathhelpers_ps1" {
  name                   = "scripts/ImageHelpers/PathHelpers.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/PathHelpers.ps1"
}

resource "azurerm_storage_blob" "image_helpers_testshelpers_ps1" {
  name                   = "scripts/ImageHelpers/TestsHelpers.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/TestsHelpers.ps1"
}

resource "azurerm_storage_blob" "image_helpers_visualstudiohelpers_ps1" {
  name                   = "scripts/ImageHelpers/VisualStudioHelpers.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/VisualStudioHelpers.ps1"
}

resource "azurerm_storage_blob" "image_helpers_test_imagehelpers_tests_ps1" {
  name                   = "scripts/ImageHelpers/test/ImageHelpers.Tests.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/test/ImageHelpers.Tests.ps1"
}

resource "azurerm_storage_blob" "image_helpers_test_pathhelpers_tests_ps1" {
  name                   = "scripts/ImageHelpers/test/PathHelpers.Tests.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/ImageHelpers/test/PathHelpers.Tests.ps1"
}

resource "azurerm_storage_blob" "tests_powershellmodules_tests_ps1" {
  name                   = "scripts/Tests/PowerShellModules.Tests.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/Tests/PowerShellModules.Tests.ps1"
}

resource "azurerm_storage_blob" "tests_visualstudio_tests_ps1" {
  name                   = "scripts/Tests/VisualStudio.Tests.ps1"
  storage_account_name   = azurerm_storage_account.winvmss1_msdn.name
  storage_container_name = azurerm_storage_container.winvmss1_msdn.name
  type                   = "Block"
  source                 = "./scripts/Tests/VisualStudio.Tests.ps1"
}
