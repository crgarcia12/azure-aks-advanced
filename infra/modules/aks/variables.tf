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

