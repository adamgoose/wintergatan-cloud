provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  load_config_file = false
  host             = module.cluster.endpoint
  token            = module.cluster.kube_config.token
  cluster_ca_certificate = base64decode(
    module.cluster.kube_config.cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    load_config_file = false
    host             = module.cluster.endpoint
    token            = module.cluster.kube_config.token
    cluster_ca_certificate = base64decode(
      module.cluster.kube_config.cluster_ca_certificate
    )
  }
}

provider "kustomization" {
  kubeconfig_raw = module.cluster.kube_config.raw_config
}

provider "cloudflare" {
  version = "~> 2.0"
  email   = "me.accounts+cloudflare@runbox.com"
  api_key = var.cloudflare_key
}
