variable "aks_cluster" {
  type = object({
    name                = string
    loadBalancerIp      = optional(string, "")
    service_mesh        = optional(string, "istio")
    auto_loadBalancerIp = optional(bool, false)
    kubernetes_version  = optional(string)
  })
  description = "Properties of the AKS cluster"

  default = {
    name = "myaks_cluster"
  }
}

variable "location" {
  type        = string
  description = "Location of the AKS cluster"
  default     = "East US"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "aks_resource_group"
}

variable "node_pool_name" {
  type        = string
  default     = "default"
  description = "Name of the AKS node pool"
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of nodes in the AKS cluster"
}


variable "client_secret" {
  type      = string
  sensitive = true
}