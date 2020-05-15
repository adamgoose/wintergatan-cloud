variable "domain" {}

resource "local_file" "ingress" {
  filename = "${path.module}/kustomize/ingress.yaml"
  content = templatefile("${path.module}/kustomize/ingress.yaml.tpl", {
    domain = var.domain
  })
}

data "kustomization" "traefik" {
  path = "${path.module}/kustomize"
}

resource "kustomization_resource" "traefik" {
  for_each = data.kustomization.traefik.ids
  manifest = data.kustomization.traefik.manifests[each.value]
  depends_on = [
    local_file.ingress
  ]
}

data "kubernetes_service" "loadbalancer" {
  metadata {
    name      = "traefik"
    namespace = "traefik"
  }

  depends_on = [
    kustomization_resource.traefik
  ]
}

resource "digitalocean_record" "main" {
  domain = var.domain
  type   = "A"
  name   = "@"
  value  = data.kubernetes_service.loadbalancer.load_balancer_ingress.0.ip
}

resource "digitalocean_record" "wildcard" {
  domain = var.domain
  type   = "CNAME"
  name   = "*"
  value  = "${var.domain}."
}
