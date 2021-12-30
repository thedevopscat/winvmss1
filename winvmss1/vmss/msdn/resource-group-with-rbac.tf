resource "azurerm_resource_group" "winvmss1_msdn" {
  name     = lower(join("-", [var.company_code, substr(var.tags["service"], 0, 10), substr(var.tags["environment"], 0, 7), lookup(var.region_code, var.location), "rg"]))
  location = var.location
  tags     = var.tags
}

# Create "Azure RG Servicename Environment XXX Cloud Engineers" Azure AD Group
resource "azuread_group" "winvmss1_msdn_rg_cloud_engineers" {
  display_name            = join(" ", ["Azure RG", title(substr(var.tags["service"], 0, 10)), upper(substr(var.tags["environment"], 0, 7), ), upper(lookup(var.region_code, var.location)), upper(var.company_code), "Cloud Engineers"])
  description             = join(" ", [upper(var.company_code), "Cloud Engineers RBAC Group - Lifecycle Managed By Terraform"])
  prevent_duplicate_names = true
  security_enabled        = true
}

# Assign The "XXX Cloud Engineers" Role To The "Azure RG Servicename Environment XXX Cloud Engineers" Azure AD Group At The Resource Group Level
resource "azurerm_role_assignment" "winvmss1_msdn_rg_cloud_engineers" {
  scope                = azurerm_resource_group.winvmss1_msdn.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.winvmss1_msdn_rg_cloud_engineers.object_id
  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
