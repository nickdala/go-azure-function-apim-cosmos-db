terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Access client_id, tenant_id, subscription_id and object_id configuration values
data "azuread_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}

data "http" "myip" {
  url = "https://api.ipify.org"
}


locals {
  postgresql_sku_name = "GP_Standard_D4s_v3"
  myip = chomp(data.http.myip.response_body)
}


resource "azurecaf_name" "resource_group" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
}

resource "azurerm_resource_group" "resource_group" {
  name     = azurecaf_name.resource_group.result
  location = var.location
}