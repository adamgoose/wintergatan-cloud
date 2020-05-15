variable "name" {}
variable "region" {}
variable "kubernetes_version" {}
variable "node_size" {}
variable "node_count" {}
variable "domain" {}

output "domain" {
  value = var.domain
}
