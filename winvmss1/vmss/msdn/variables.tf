variable "company_code" {
  type    = string
  default = "dk"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "region_code" {
  type        = map(any)
  description = "Short code used to identify the Azure region."
  default = {
    "northeurope" = "neu"
    "westeurope"  = "weu"
  }
}

# All Tags should be in lowercase
variable "tags" {
  type = map(any)
  default = {
    service           = "winvmss1"
    environment       = "msdn"
    iacversion        = "1.0"
    expireson         = ""
    description       = "creates vmss to be used by vm scale set for azure devops self-hosted agents"
    maintenancewindow = "n/a disk image, not powered on"
    hoursofoperation  = ""
    businessowner     = ""
    costcentre        = "sap cost centre goes here"
    project           = "azure self hosted agent vm image"
    department        = "technology"
    confidentiality   = ""
    compliance        = ""
    creator           = "davek"
    codepath          = "az/winvmss1/vmss/msdn"
  }
}
