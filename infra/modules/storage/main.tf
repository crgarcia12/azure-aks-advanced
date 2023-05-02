
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

resource "azurerm_storage_account" "backupstorage" {
  name                     = "${replace(var.prefix, "-", "")}stor"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.location
  }
}

resource "azurerm_storage_container" "backupcontainer" {
  name                  = "mycontainer"
  storage_account_name  = azurerm_storage_account.backupstorage.name
  container_access_type = "private"
}

output "container_name" {
  value = azurerm_storage_container.backupcontainer.name
}

output "storage_name" {
  value = azurerm_storage_account.backupstorage.name
}




