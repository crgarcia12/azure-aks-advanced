locals {
  prefix          = "crgar-aks-advanced"
  location        = "switzerlandnorth"
  tenant_id       = "b317d745-eb97-4068-9a14-a2e967b0b72e"
  subscription_id = "14506188-80f8-4dc6-9b28-250051fc4ee4"
}

terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "crgar-aks-advanced-terraform-rg"
    storage_account_name = "crgaraksadvancedtfm"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "spoke_rg" {
  name     = "${local.prefix}-rg"
  location = local.location
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "acctest-01"
  location            = azurerm_resource_group.spoke_rg.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "backupstorage" {
  source              = "./modules/storage"
  prefix              = local.prefix
  location            = local.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
}

module "aks" {
  source                     = "./modules/aks"
  prefix                     = local.prefix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.spoke_rg.name
  resource_group_id          = azurerm_resource_group.spoke_rg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  container_name             = module.backupstorage.container_name
  storage_name               = module.backupstorage.storage_name
  subscription_id            = local.subscription_id
  tenant_id                  = local.tenant_id
}

module "kv" {
  source                                   = "./modules/kv"
  prefix                                   = local.prefix
  location                                 = local.location
  resource_group_name                      = azurerm_resource_group.spoke_rg.name
  resource_group_id                        = azurerm_resource_group.spoke_rg.id
  user_assigned_managed_identity_client_id = "8650d324-6bba-47eb-b137-ec152aa03da3"
  tenant_id                                = local.tenant_id
}