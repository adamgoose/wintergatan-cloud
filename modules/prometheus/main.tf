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
      baseURL: https://graphic.${var.domain}/alerting
      prefixURL: /alerting
      ingress:
        enabled: true
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-cloudflare
          traefik.ingress.kubernetes.io/router.tls: "true"
        hosts:
          - graphic.${var.domain}/alerting
        tls:
          - secretName: graphic-tls
            hosts:
              - graphic.${var.domain}
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 0
          maxUnavailable: 100%
    server:
      baseURL: https://graphic.${var.domain}/prometheus
      prefixURL: /prometheus
      retention: 365d
      ingress:
        enabled: true
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt
          traefik.ingress.kubernetes.io/router.tls: "true"
        hosts:
          - graphic.${var.domain}/prometheus
        tls:
          - secretName: graphic-tls
            hosts:
              - graphic.${var.domain}
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 0
          maxUnavailable: 100%
EOF
  ]

  depends_on = [
    kubernetes_namespace.prometheus
  ]
}
