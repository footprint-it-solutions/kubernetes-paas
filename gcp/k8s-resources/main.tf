terraform {}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "europe-west2-b"
}

data "google_client_config" "provider" {}

##### int gke provider setup
data "google_container_cluster" "int_gke" {
  name     = local.int_cluster.name
  location = var.region
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.int_gke.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.int_gke.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.provider.access_token
  alias                  = "int"
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.int_gke.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.int_gke.master_auth.0.cluster_ca_certificate)
    token                  = data.google_client_config.provider.access_token
  }
  alias = "int"
}


##### ext gke provider setup
data "google_container_cluster" "ext_gke" {
  name     = local.ext_cluster.name
  location = var.region
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.ext_gke.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.ext_gke.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.provider.access_token
  alias                  = "ext"
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.ext_gke.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.ext_gke.master_auth.0.cluster_ca_certificate)
    token                  = data.google_client_config.provider.access_token
  }
  alias = "ext"
}

locals {
  # peer_lb_ips = flatten([
  #   for mapping in data.aws_lb.int_eks_internal_nlb.subnet_mapping : [
  #     mapping.private_ipv4_address
  #   ]
  # ])

  int_cluster = {
    name = "int-gke"
    shared_namespaces = {
      "monitoring" = {
        "labels" = {
          "istio-injection" = "enabled"
        }
      },
      "oauth2-proxy" = {
        "labels" = {}
      }
    }
    kyverno_namespace                = "kyverno"
    region                           = var.region
    custom_docker_registry           = var.custom_docker_registry
    domainzones                      = ["gcp.your.domain"]
    domain                           = "gcp.your.domain"
    prometheus_namespace             = "monitoring"
    grafana_namespace                = "monitoring"
    certmanager_namespace            = "cert-manager"
    elk_namespace                    = "monitoring"
    filebeat_namespace               = "monitoring"
    oauth2_proxy_namespace           = "oauth2-proxy"
    istio_external_ips               = []
    istio_haproxy_svc_ip             = ""
    istio_helloworld_version         = "v1"
    istio_meshid                     = "mesh1"
    istio_network_name               = "int-net"
    istio_ca_key                     = var.int_istio_ca_key
    istio_ca_cert                    = "int-gke/ca-cert.pem"
    istio_cert_chain                 = "int-gke/cert-chain.pem"
    istio_ewgw_load_balancer_type    = "Internal"
    istio_ingress_load_balancer_type = "Internal"
    istio_root_cert                  = "int-gke/root-cert.pem"
    istio_remote_pilot_address       = "" # stays empty in int
    istio_service_type               = "LoadBalancer"
    istio_virtual_services           = []
    aws_account_id                   = ""   # stays emtpy in GCP
    peer_lb_ips                      = [""] # was - local.peer_lb_ips
    lb_dns_name                      = ""   # was - data.aws_lb.int_eks_internal_nlb.dns_name
    enabled_helm_releases = {
      cert-manager       = true,
      cluster-autoscaler = false,
      elk                = true,
      external-dns       = true,
      filebeat           = true
      grafana            = true,
      istio              = true,
      istio-base         = true,
      istio_helloworld   = true,
      k8s-auditor        = true,
      kyverno            = true,
      prometheus         = true,
      oauth2-proxy       = true,
    }
    gcp_project                = var.project_id
    github_client_secret       = var.github_client_secret
    github_client_id           = var.github_client_id
    oauth2_proxy_namespace     = "oauth2-proxy"
    oauth2_proxy_cookie_secret = var.oauth2_proxy_cookie_secret
    oauth2_proxy_enabled       = true
  }

  ext_cluster = {
    name = "ext-gke"
    shared_namespaces = {
      "monitoring" = {
        "labels" = {
          "istio-injection" = "enabled"
        }
      }
    }
    kyverno_namespace                = "kyverno"
    region                           = var.region
    custom_docker_registry           = var.custom_docker_registry
    domainzones                      = ["gcp.your.domain"]
    domain                           = "gcp.your.domain"
    prometheus_namespace             = "monitoring"
    grafana_namespace                = "monitoring"
    certmanager_namespace            = "cert-manager"
    elk_namespace                    = "monitoring"
    filebeat_namespace               = "monitoring"
    oauth2_proxy_namespace           = "oauth2-proxy"
    istio_external_ips               = []
    istio_haproxy_svc_ip             = ""
    istio_helloworld_version         = "v2"
    istio_meshid                     = "mesh1"
    istio_network_name               = "ext-net"
    istio_ca_key                     = var.ext_istio_ca_key
    istio_ca_cert                    = "ext-gke/ca-cert.pem"
    istio_cert_chain                 = "ext-gke/cert-chain.pem"
    istio_ewgw_load_balancer_type    = "Internal"
    istio_ingress_load_balancer_type = "External"
    istio_root_cert                  = "ext-gke/root-cert.pem"
    istio_remote_pilot_address       = module.int_cluster_data.resources.istio_eastwestgateway_service.status.0.load_balancer.0.ingress.0.ip
    istio_service_type               = "LoadBalancer"
    istio_virtual_services = [
      "elasticsearch",
      "logstash"
    ]
    aws_account_id = ""   # stays emtpy in GCP
    peer_lb_ips    = [""] # was - local.peer_lb_ips
    lb_dns_name    = ""   # was - data.aws_lb.int_eks_internal_nlb.dns_name
    enabled_helm_releases = {
      cert-manager       = true,
      cluster-autoscaler = false,
      elk                = false,
      external-dns       = true,
      filebeat           = false,
      grafana            = false,
      istio              = true,
      istio-base         = true,
      istio_helloworld   = true,
      k8s-auditor        = false,
      kyverno            = true,
      prometheus         = false,
      oauth2-proxy       = false,
    }
    gcp_project                = var.project_id
    github_client_secret       = ""
    github_client_id           = ""
    oauth2_proxy_namespace     = "oauth2-proxy"
    oauth2_proxy_cookie_secret = ""
    oauth2_proxy_enabled       = false
  }
}

module "int_cluster" {
  source  = "../../k8s"
  cluster = local.int_cluster

  providers = {
    kubernetes.cluster = kubernetes.int
    helm.cluster       = helm.int
  }
}

module "int_cluster_data" {
  source = "../../k8s/modules/k8s-data"

  depends_on = [
    module.int_cluster
  ]

  providers = {
    kubernetes.cluster = kubernetes.int
  }
}

module "ext_cluster" {
  source  = "../../k8s"
  cluster = local.ext_cluster

  depends_on = [
    module.int_cluster
  ]

  providers = {
    kubernetes.cluster = kubernetes.ext
    helm.cluster       = helm.ext
  }
}

module "istio_secrets" {
  source = "../../k8s/modules/istio-secrets"
  providers = {
    kubernetes.int = kubernetes.int,
    kubernetes.ext = kubernetes.ext,
  }

  ext_api_endpoint = "https://${data.google_container_cluster.ext_gke.endpoint}"
  ext_ca_data      = data.google_container_cluster.ext_gke.master_auth.0.cluster_ca_certificate
  ext_cluster_name = local.ext_cluster.name

  depends_on = [
    module.int_cluster,
    module.ext_cluster,
  ]
}
