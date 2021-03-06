resource "kubernetes_namespace" "monibot" {
  metadata {
    name = "monibot"
  }
}

resource "local_file" "ingress" {
  filename = "${path.module}/kustomize/ingress.yaml"
  content = templatefile("${path.module}/kustomize/ingress.yaml.tpl", {
    domain = var.domain
  })
}

resource "kubernetes_secret" "config" {
  metadata {
    name      = "monibot-config"
    namespace = kubernetes_namespace.monibot.metadata[0].name
  }
  data = {
    "config.json" = jsonencode({
      token = var.discord_bot_token
      port  = 9100
    })
  }
}

data "kustomization" "monibot" {
  path = "${path.module}/kustomize"
}

resource "kustomization_resource" "monibot" {
  for_each = data.kustomization.monibot.ids
  manifest = data.kustomization.monibot.manifests[each.value]

  depends_on = [
    kubernetes_secret.config,
    local_file.ingress
  ]
}
