variable "domain" {}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "prometheus"
  version    = "11.2.3"

  values = [<<EOF
    alertmanager:
      baseURL: https://am.${var.domain}
      ingress:
        enabled: true
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt
          traefik.ingress.kubernetes.io/router.tls: "true"
        hosts:
          - am.${var.domain}
        tls:
          - secretName: am-tls
            hosts:
              - am.${var.domain}
    server:
      baseURL: https://prom.${var.domain}
      ingress:
        enabled: true
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt
          traefik.ingress.kubernetes.io/router.tls: "true"
        hosts:
          - prom.${var.domain}
        tls:
          - secretName: prom-tls
            hosts:
              - prom.${var.domain}
EOF
  ]

  depends_on = [
    kubernetes_namespace.prometheus
  ]
}
