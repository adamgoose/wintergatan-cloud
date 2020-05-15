resource "digitalocean_kubernetes_cluster" "main" {
  name    = var.name
  region  = var.region
  version = var.kubernetes_version

  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    node_count = var.node_count
  }
}

output "endpoint" {
  value = digitalocean_kubernetes_cluster.main.endpoint
}

output "kube_config" {
  value = digitalocean_kubernetes_cluster.main.kube_config[0]
}
