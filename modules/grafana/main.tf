variable "domain" {}
variable "discord" {
  type = object({
    client_id     = string
    client_secret = string
  })
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.grafana.metadata[0].name
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "grafana"
  version    = "5.0.24"

  values = [
    yamlencode({
      ingress = {
        enabled = true
        annotations = {
          "cert-manager.io/cluster-issuer"           = "letsencrypt"
          "traefik.ingress.kubernetes.io/router.tls" = "true"
        }
        hosts = ["grafana.${var.domain}"]
        tls = [{
          secretName = "grafana-tls"
          hosts      = ["grafana.${var.domain}"]
        }]
      }
      persistence = {
        enabled = true
        size    = "1Gi"
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [{
            name     = "k8s.prometheus"
            type     = "prometheus"
            access   = "proxy"
            url      = "http://prometheus-server.prometheus"
            editable = false
            version  = 1
          }]
        }
      }
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [{
            name            = "default"
            type            = "file"
            disableDeletion = true
            editable        = false
            options = {
              path = "/var/lib/grafana/dashboards/default"
            }
          }]
        }
      }
      dashboards = {
        default = {
          prometheus-stats = {
            gnetId     = 2
            revision   = 2
            datasource = "k8s.prometheus"
          }
          node-exporter = {
            gnetId     = 11074
            revision   = 2
            datasource = "k8s.prometheus"
          }
          cert-manager = {
            gnetId     = 11011
            revision   = 1
            datasource = "k8s.prometheus"
          }
          kube-deployments = {
            gnetId     = 8588
            revision   = 1
            datasource = "k8s.prometheus"
          }
          kube-pods = {
            gnetId     = 6588
            revision   = 1
            datasource = "k8s.prometheus"
          }
          cluster-monitoring-k8s = {
            gnetId     = 10000
            revision   = 1
            datasource = "k8s.prometheus"
          }
        }
      }
      "grafana.ini" : {
        server = {
          domain   = "grafana.${var.domain}"
          root_url = "https://%(domain)s"
        }
        "auth.anonymous" = {
          enabled = true
        }
        "auth.generic_oauth" = {
          enabled       = true
          client_id     = var.discord.client_id
          client_secret = var.discord.client_secret
          scopes        = "identify email guilds"
          auth_url      = "https://discord.com/api/oauth2/authorize"
          token_url     = "https://discord.com/api/oauth2/token"
          api_url       = "https://discord.com/api/users/@me"
          allow_sign_up = true
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.grafana
  ]
}
