variable "aks_cluster" {
  type = object({
    name                = string
    location            = optional(string)
    resource_group_name = optional(string)
    dns_prefix          = optional(string)
    node_count          = optional(number)
    node_size           = optional(string)
    kubernetes_version  = optional(string)
    service_mesh        = optional(string, null)
    loadBalancerIp      = optional(string, null)
  })
  default = {
    name                = "default-aks"
    location            = "East US"
    resource_group_name = "example-resources"
    dns_prefix          = "defaultaksdns"
    node_count          = 1
    node_size           = "standard_b2pls_v2"
    kubernetes_version  = "1.28.5"
  }
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
