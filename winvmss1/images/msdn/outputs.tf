# output "build_location" {
#   value = azurerm_resource_group.winvmss1_msdn.location
# }

output "build_resource_group" {
  value = azurerm_resource_group.winvmss1_msdn.name
}

output "build_vm_id" {
  value = azurerm_windows_virtual_machine.winvmss1_msdn_windows_vm.id
}

output "build_vm_name" {
  value = azurerm_windows_virtual_machine.winvmss1_msdn_windows_vm.name
}

# output "hostname" {
#   value = azurerm_windows_virtual_machine.winvmss1_msdn_windows_vm.name
# }
