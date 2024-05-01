variable "aks_cluster" {
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    dns_prefix          = string
    node_count          = number
    node_size           = string
    kubernetes_version  = string
    service_mesh        = optional(string, null)
    loadBalancerIp      = optional(string, null)
  })
  default = {
    name                = "default-aks"
    location            = "East US"
    resource_group_name = "default-resource-group"
    dns_prefix          = "defaultaksdns"
    node_count          = 1
    node_size           = "Standard_DS2_v2"
    kubernetes_version  = "1.18.14"
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
