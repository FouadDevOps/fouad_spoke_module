variable "aks_cluster" {
  type = object({
    name                = string  // Name must be provided by the user of the module
    location            = optional(string, "East US")
    resource_group_name = optional(string, "example-resources")
    dns_prefix          = optional(string, "defaultaksdns")
    node_count          = optional(number, 1)  // Default updated based on your first post
    node_size           = optional(string, "standard_b2pls_v2")  // Default updated based on your first post
    kubernetes_version  = optional(string, "1.28.5")  // Default updated based on your first post
    service_mesh        = optional(string, null)  // Optional, no default service mesh enabled
    loadBalancerIp      = optional(string, null)  // Optional, no default IP
  })
  description = "Configuration for the AKS cluster, allowing optional overrides for most properties"
}

variable "sp_client_id" {
  description = "The Client ID for the Service Principal."
  type        = string
  sensitive   = true
}

variable "sp_client_secret" {
  description = "The Client Secret for the Service Principal."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The Azure Tenant ID that owns the service principal."
  type        = string
  sensitive = true
}
