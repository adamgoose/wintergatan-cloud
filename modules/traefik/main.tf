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
