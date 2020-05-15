variable "do_token" {}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "do" {
  metadata {
    name      = "do"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }
  data = {
    access-token = var.do_token
  }
}

data "kustomization" "cert-manager-crds" {
  path = "${path.module}/kustomize"
}

resource "kustomization_resource" "cert-manager-crds" {
  for_each   = data.kustomization.cert-manager-crds.ids
  manifest   = data.kustomization.cert-manager-crds.manifests[each.value]
  depends_on = [kubernetes_secret.do]
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v0.15.0"
  depends_on = [kustomization_resource.cert-manager-crds]
}
