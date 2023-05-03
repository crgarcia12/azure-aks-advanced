resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.prefix, "-", "")}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "${var.prefix}-aks"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = "${var.prefix}-aks"
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = ["10459d9f-98d8-48e0-b3fb-4f0b92a85ba4"]
  }


  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = var.network_plugin_mode
    ebpf_data_plane     = var.ebpf_data_plane
    load_balancer_sku   = "standard"
  }

  storage_profile {
    blob_driver_enabled = true
    file_driver_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  tags = {
    environment = var.location
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "user-pool-1" {
  name                  = "userpool1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1
  zones                 = ["1"]
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 1
  mode                  = "User"
  node_taints           = ["app=demoapp:NoSchedule"]
}

resource "azurerm_kubernetes_cluster_node_pool" "user-pool-2" {
  name                  = "userpool2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1
  zones                 = ["2"]
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 1
  mode                  = "User"
  node_taints           = ["app=demoapp:NoSchedule"]   

}

# TODO: IN PROGRESS :(
# resource "azapi_resource" "backup_extension" {
#   type      = "Microsoft.KubernetesConfiguration/extensions@2022-11-01"
#   parent_id = azurerm_kubernetes_cluster.aks.id
#   name      = "azure-aks-backup"

#   body = jsonencode({
#     properties = {
#       extensionType = "microsoft.dataprotection.kubernetes"
#       configurationSettings = {
#         blobContainer                = var.container_name
#         storageAccount               = var.storage_name
#         storageAccountResourceGroup  = var.resource_group_name
#         storageAccountSubscriptionId = var.subscription_id
#         tenant_id                    = var.tenant_id
#       }
#     }
#   })
# }

resource "azurerm_role_assignment" "aks-connection-to-acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}