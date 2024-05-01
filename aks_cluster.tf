# AKS Cluster Resource
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster.name
  location            = var.aks_cluster.location
  resource_group_name = var.aks_cluster.resource_group_name
  dns_prefix          = var.aks_cluster.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.aks_cluster.node_count
    vm_size    = var.aks_cluster.node_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }



}

# Null Resource for Service Mesh Configuration
resource "null_resource" "service_mesh" {
  count = (var.aks_cluster.service_mesh != null && var.aks_cluster.service_mesh == "istio") || (var.aks_cluster.loadBalancerIp != null) ? 1 : 0

  triggers = {
    cluster_name = azurerm_kubernetes_cluster.aks.name
    service_mesh = var.aks_cluster.service_mesh != null ? var.aks_cluster.service_mesh : ""
    loadBalancerIp = var.aks_cluster.loadBalancerIp != null ? var.aks_cluster.loadBalancerIp : ""
  }

  provisioner "local-exec" {
    when = create
    working_dir = "${path.module}/scripts"
    command = "./service_mesh_cluster_yaml_input.sh add $CLUSTER_NAME $SERVICE_MESH $LOAD_BALANCER_IP"
    environment = {
      CLUSTER_NAME = self.triggers.cluster_name
      SERVICE_MESH = self.triggers.service_mesh
      LOAD_BALANCER_IP = self.triggers.loadBalancerIp
    }
  }

  provisioner "local-exec" {
    when = destroy
    working_dir = "${path.module}/scripts"
    command = "./service_mesh_cluster_yaml_input.sh rm $CLUSTER_NAME $SERVICE_MESH $LOAD_BALANCER_IP"
    environment = {
      CLUSTER_NAME = self.triggers.cluster_name
      SERVICE_MESH = self.triggers.service_mesh
      LOAD_BALANCER_IP = self.triggers.loadBalancerIp
    }
  }
}

# Null Resource for Load Balancer IP Configuration
resource "null_resource" "loadBalancerIp" {
  count = (var.aks_cluster.service_mesh != null && var.aks_cluster.service_mesh == "istio") || (var.aks_cluster.loadBalancerIp != null) ? 1 : 0

  triggers = {
    cluster_name = azurerm_kubernetes_cluster.aks.name
    loadBalancerIp = var.aks_cluster.loadBalancerIp != null ? var.aks_cluster.loadBalancerIp : ""
    service_mesh = var.aks_cluster.service_mesh != null ? var.aks_cluster.service_mesh : ""
  }

  provisioner "local-exec" {
    when = create
    working_dir = "${path.module}/scripts"
    command = "./loadBalancerIp_cluster_yaml_input.sh add $CLUSTER_NAME $LOAD_BALANCER_IP $SERVICE_MESH"
    environment = {
      CLUSTER_NAME = self.triggers.cluster_name
      LOAD_BALANCER_IP = self.triggers.loadBalancerIp
      SERVICE_MESH = self.triggers.service_mesh
    }
  }

  provisioner "local-exec" {
    when = destroy
    working_dir = "${path.module}/scripts"
    command = "./loadBalancerIp_cluster_yaml_input.sh rm $CLUSTER_NAME $LOAD_BALANCER_IP $SERVICE_MESH"
    environment = {
      CLUSTER_NAME = self.triggers.cluster_name
      LOAD_BALANCER_IP = self.triggers.loadBalancerIp
      SERVICE_MESH = self.triggers.service_mesh
    }
  }
}