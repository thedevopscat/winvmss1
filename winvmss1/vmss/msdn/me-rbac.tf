data "azuread_user" "cloud_engineer" {
  user_principal_name = join("", ["cloudengineer@", var.engineers_domain])
}

# Make Cloud Engineer Account A Member Of "Azure RG Servicename Environment XXX Cloud Engineers" Azure AD Group
resource "azuread_group_member" "cloud_engineers" {
  group_object_id  = azuread_group.winvmss1_msdn_rg_cloud_engineers.id
  member_object_id = data.azuread_user.cloud_engineer.id
}

# variable "engineers_full_name" {
#   type    = string
#   default = "David Kent"
# }

variable "engineers_domain" {
  type    = string
  default = "thedevopscat.co.uk"
}

