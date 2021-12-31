resource "null_resource" "create_stw_wrapper_ps1" {
  provisioner "local-exec" {
    command     = <<POWERSHELL
Add-Content -Path './scripts/stw-wrapper.ps1' -Value ('
# stw-wrapper.ps1 - Im The STW-Wrapper All The Other Wrappers Are Crapper....

$ProgressPreference = "SilentlyContinue"

If (-Not (Test-Path "C:\image")) {
    New-Item -ItemType "Directory" -Path "C:\image" -Force | Out-Null
}

If (-Not (Test-Path "C:\Scripts")) {
  New-Item -ItemType "Directory" -Path "C:\Scripts" -Force | Out-Null
}

If (-Not (Test-Path "C:\Logs")) {
  New-Item -ItemType "Directory" -Path "C:\Logs" -Force | Out-Null
}

Copy-Item -Path ".\scripts\run-once.ps1" -Destination "C:\Scripts" -Force | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "Build" -PropertyType "String" -Value "powershell.exe C:\Scripts\run-once.ps1" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -PropertyType "DWord" -Value "00000001" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -PropertyType "String" -Value "zzVM_ACCOUNT" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -PropertyType "String" -Value "zzVM_PASSWORD" -Force | Out-Null

Copy-Item -Path ".\scripts\ImageHelpers" -Destination "C:\Program Files\WindowsPowerShell\Modules\ImageHelpers" -Recurse
Copy-Item -Path ".\scripts\Tests" -Destination "C:\image\Tests" -Recurse
Copy-Item -Path ".\scripts\toolset-2019.json" -Destination "C:\image\toolset.json" -Force | Out-Null

.\scripts\Configure-Antivirus.ps1
.\scripts\Install-PowerShellModules.ps1
.\scripts\Initialize-VM.ps1
.\scripts\Install-VS.ps1

If (Test-Path "C:\image") {
    Remove-Item -Path "C:\image\" -Recurse -Force | Out-Null
}

# Remove The stw-wrapper From Custom Script Extension Folder
If (Test-Path "./scripts/stw-wrapper.ps1") { Remove-Item -Path "./scripts/stw-wrapper.ps1" -Force | Out-Null }

shutdown /r /t 10 /f
exit 0
')
POWERSHELL
    interpreter = ["pwsh", "-Command"]
  }
}

# Add Credentials From Environment Variables To The Scripts
resource "null_resource" "add_credentials_to_stw_wapper" {
  provisioner "local-exec" {
    command     = <<POWERSHELL
Start-Sleep -Seconds "5"
(Get-Content -Path ./scripts/stw-wrapper.ps1).Replace("zzVM_ACCOUNT", $env:VM_ACCOUNT) | Set-Content -Path ./scripts/stw-wrapper.ps1 -Force
(Get-Content -Path ./scripts/stw-wrapper.ps1).Replace("zzVM_PASSWORD", $env:VM_PASSWORD) | Set-Content -Path ./scripts/stw-wrapper.ps1 -Force
POWERSHELL
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [
    null_resource.create_stw_wrapper_ps1
  ]
}

resource "null_resource" "delete_stw_wapper" {
  provisioner "local-exec" {
    command     = <<POWERSHELL
If (Test-Path "./scripts/stw-wrapper.ps1") {
    Remove-Item -Path "./scripts/stw-wrapper.ps1" -Force
}
POWERSHELL
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [
    azurerm_storage_blob.stw_wrapper_ps1
  ]
}
