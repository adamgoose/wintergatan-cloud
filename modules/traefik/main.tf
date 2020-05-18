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

data "cloudflare_zones" "main" {
  filter {
    name   = var.domain
    status = "active"
    paused = false
  }
}

resource "cloudflare_record" "traefik" {
  zone_id = data.cloudflare_zones.main.zones.0.id
  name    = "traefik"
  value   = data.kubernetes_service.loadbalancer.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "graphic" {
  zone_id = data.cloudflare_zones.main.zones.0.id
  name    = "graphic"
  value   = data.kubernetes_service.loadbalancer.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "metrics" {
  zone_id = data.cloudflare_zones.main.zones.0.id
  name    = "metrics"
  value   = data.kubernetes_service.loadbalancer.load_balancer_ingress.0.ip
  type    = "A"
  ttl     = 3600
}
