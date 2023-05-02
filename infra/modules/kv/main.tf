variable "prefix" {
  description = "prefix"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "resource_group_name" {
  description = "RG Name"
  type        = string
}

variable "resource_group_id" {
  description = "RG id"
  type        = string
}

variable "user_assigned_managed_identity_client_id" {
  description = "User Assigned Managed Identity Client ID"
  type        = string
}

variable "tenant_id" {
  description = "tenant_id"
  type        = string
}

##################################################
#                   Resources
##################################################


resource "azurerm_key_vault" "example" {
  name                        = "${var.prefix}-aks"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.user_assigned_managed_identity_client_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}