################################
#         Generics
################################

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
  description = "RG Name"
  type        = string
}

################################
#         AKS
################################
variable "network_plugin_mode" {
  description = "network plugin mode"
  type        = string
  default     = "Overlay"
}

variable "ebpf_data_plane" {
  description = "ebpf_data_plane"
  type        = string
  default     = "cilium"
}

variable "log_analytics_workspace_id" {
  description = "log_analytics_workspace_id"
  type        = string
}

################################
#         Storage
################################
variable "container_name" {
  type = string
}
variable "storage_name" {
  type = string
}
variable "subscription_id" {
  type = string
}


################################
#         Backup
################################
variable "tenant_id" {
  type = string
}