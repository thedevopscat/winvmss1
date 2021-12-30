terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.13"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.89"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
  required_version = "~> 1.1"
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}
