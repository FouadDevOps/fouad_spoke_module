resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster.name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "fouad"
  depends_on          = [azurerm_resource_group.aks_rg]

  default_node_pool {
    name       = var.node_pool_name
    node_count = var.node_count
    vm_size    = "standard_b2pls_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}


# Null Resource for Load Balancer IP Configuration
resource "null_resource" "loadBalancerIp" {
  count = var.aks_cluster.loadBalancerIp != null || var.aks_cluster.auto_loadBalancerIp == true ? 1 : 0

  triggers = {
    cluster_name        = azurerm_kubernetes_cluster.aks_cluster.name
    resource_group_name = "MC_aks_resource_group_myaks_cluster_eastus"
    vnet_name           = "aks-vnet-17017758"
    subnet_name         = "aks-subnet"
    loadBalancerIp      = var.aks_cluster.loadBalancerIp != null ? var.aks_cluster.loadBalancerIp : ""

  }

  provisioner "local-exec" {
    when        = create
    working_dir = "${path.module}/scripts"
    command = "chmod +x loadBalancerIp_cluster_yaml_input.sh; ./loadBalancerIp_cluster_yaml_input.sh add $CLUSTER_NAME \"$LOAD_BALANCER_IP\" \"$RESOURCE_GROUP\" \"$VNET_NAME\" \"$SUBNET_NAME\""
    environment = {
      CLUSTER_NAME     = self.triggers.cluster_name
      LOAD_BALANCER_IP = self.triggers.loadBalancerIp
      RESOURCE_GROUP   = self.triggers.resource_group_name
      VNET_NAME        = self.triggers.vnet_name
      SUBNET_NAME      = self.triggers.subnet_name
    }
  }

  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/scripts"
    command = "chmod +x loadBalancerIp_cluster_yaml_input.sh; ./loadBalancerIp_cluster_yaml_input.sh add $CLUSTER_NAME \"$LOAD_BALANCER_IP\" \"$RESOURCE_GROUP\" \"$VNET_NAME\" \"$SUBNET_NAME\""
    environment = {
      CLUSTER_NAME     = self.triggers.cluster_name
      LOAD_BALANCER_IP = self.triggers.loadBalancerIp
      RESOURCE_GROUP   = self.triggers.resource_group_name
      VNET_NAME        = self.triggers.vnet_name
      SUBNET_NAME      = self.triggers.subnet_name
    }
  }
}


# # Null Resource for Service Mesh Configuration
# resource "null_resource" "service_mesh" {
#   count = var.aks_cluster.service_mesh != null || var.aks_cluster.service_mesh == "istio" ? 1 : 0

#   triggers = {
#     cluster_name   = azurerm_kubernetes_cluster.aks_cluster.name
#     service_mesh   = var.aks_cluster.service_mesh
#     # loadBalancerIp = var.aks_cluster.loadBalancerIp != null ? var.aks_cluster.loadBalancerIp : ""
#   }

#   provisioner "local-exec" {
#     when        = create
#     working_dir = "${path.module}/scripts"
#     command     = "chmod +x service_mesh_cluster_yaml_input.sh; ./service_mesh_cluster_yaml_input.sh add $CLUSTER_NAME $SERVICE_MESH"
#     environment = {
#       CLUSTER_NAME     = self.triggers.cluster_name
#       SERVICE_MESH     = self.triggers.service_mesh
#       LOAD_BALANCER_IP = self.triggers.loadBalancerIp
#       RESOURCE_GROUP   = self.triggers.resource_group_name
#       VNET_NAME        = self.triggers.vnet_name
#       SUBNET_NAME      = self.triggers.subnet_name
#     }
#   }

#   provisioner "local-exec" {
#     when        = destroy
#     working_dir = "${path.module}/scripts"
#     command     = "chmod +x service_mesh_cluster_yaml_input.sh; ./service_mesh_cluster_yaml_input.sh rm $CLUSTER_NAME $SERVICE_MESH"
#     environment = {
#       CLUSTER_NAME     = self.triggers.cluster_name
#       SERVICE_MESH     = self.triggers.service_mesh
#       LOAD_BALANCER_IP = self.triggers.loadBalancerIp
#       RESOURCE_GROUP   = self.triggers.resource_group_name
#       VNET_NAME        = self.triggers.vnet_name
#       SUBNET_NAME      = self.triggers.subnet_name
#     }
#   }
# }