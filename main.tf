module "cluster" {
  source = "./modules/cluster"

  name               = "wintergatan"
  region             = "ams3"
  kubernetes_version = "1.17.5-do.0"
  node_size          = "s-2vcpu-2gb"
  node_count         = 2
  domain             = "wintergatan.enge.me"
}

resource "local_file" "kubeconfig" {
  filename = "${path.root}/kubeconfig.yaml"
  content  = module.cluster.kube_config.raw_config
}

module "cert-manager" {
  source = "./modules/cert-manager"

  do_token = var.do_token
}

module "traefik" {
  source = "./modules/traefik"

  domain = module.cluster.domain
}
