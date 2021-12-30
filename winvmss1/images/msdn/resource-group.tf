resource "azurerm_resource_group" "winvmss1_msdn" {
  name     = lower(join("-", [var.company_code, substr(var.tags["service"], 0, 10), "imagevm", substr(var.tags["environment"], 0, 7), lookup(var.region_code, var.location), "rg"]))
  location = var.location
  tags     = var.tags
}
