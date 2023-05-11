terraform {}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_lb" "int_eks_internal_nlb" {
  name = "int-eks-internal" // TODO this needs a dynamic way of specifying the name
}

data "aws_lb" "ext_eks_internal_nlb" {
  name = "ext-eks-internal" // TODO this needs a dynamic way of specifying the name
}

###### int eks provider setup
data "aws_eks_cluster" "int_eks" {
  name = local.int_cluster.name
}
data "aws_eks_cluster_auth" "int_eks" {
  name = local.int_cluster.name
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.int_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.int_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.int_eks.token
  alias                  = "int"
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.int_eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.int_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.int_eks.token
  }
  alias = "int"
}

###### ext eks provider setup
data "aws_eks_cluster" "ext_eks" {
  name = local.ext_cluster.name
}
data "aws_eks_cluster_auth" "ext_eks" {
  name = local.ext_cluster.name
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.ext_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.ext_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.ext_eks.token
  alias                  = "ext"
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.ext_eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ext_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.ext_eks.token
  }
  alias = "ext"
}

locals {
  int_cluster = {
    name = "int-eks"
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
    region                           = "eu-west-1"
    custom_docker_registry           = var.custom_docker_registry
    domainzones                      = ["aws.your.domain"]
    domain                           = "aws.your.domain"
    prometheus_namespace             = "monitoring"
    grafana_namespace                = "monitoring"
    certmanager_namespace            = "cert-manager"
    elk_namespace                    = "monitoring"
    filebeat_namespace               = "monitoring"
    istio_external_ips               = ["172.21.75.75"]
    istio_haproxy_svc_ip             = "172.20.75.75"
    istio_meshid                     = "mesh1"
    istio_network_name               = "int-net"
    istio_ca_key                     = var.int_istio_ca_key
    istio_ca_cert                    = "int-eks/ca-cert.pem"
    istio_cert_chain                 = "int-eks/cert-chain.pem"
    istio_helloworld_version         = "v1"
    istio_ewgw_load_balancer_type    = "internal"
    istio_ingress_load_balancer_type = "internal"
    istio_root_cert                  = "int-eks/root-cert.pem"
    istio_remote_pilot_address       = "" # stays empty in int
    istio_service_type               = "NodePort"
    istio_virtual_services           = []
    aws_account_id                   = data.aws_caller_identity.current.account_id
    peer_lb_ips = flatten([
      for mapping in data.aws_lb.ext_eks_internal_nlb.subnet_mapping : [
        mapping.private_ipv4_address
      ]
    ])
    lb_dns_name = data.aws_lb.int_eks_internal_nlb.dns_name
    enabled_helm_releases = {
      cert-manager       = true,
      cluster-autoscaler = true,
      elk                = true,
      external-dns       = true,
      filebeat           = true,
      grafana            = true,
      istio              = true,
      istio-base         = true,
      istio_helloworld   = true,
      k8s-auditor        = true,
      kyverno            = true,
      prometheus         = true,
      oauth2-proxy       = true,
    }
    gcp_project                = ""
    github_client_secret       = var.github_client_secret
    github_client_id           = var.github_client_id
    oauth2_proxy_namespace     = "oauth2-proxy"
    oauth2_proxy_cookie_secret = var.oauth2_proxy_cookie_secret
    oauth2_proxy_enabled       = true
  }

  ext_cluster = {
    name = "ext-eks"
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
    region                           = "eu-west-1"
    custom_docker_registry           = var.custom_docker_registry
    domainzones                      = ["aws.your.domain"]
    domain                           = "aws.your.domain"
    prometheus_namespace             = "monitoring"
    grafana_namespace                = "monitoring"
    certmanager_namespace            = "cert-manager"
    elk_namespace                    = "monitoring"
    filebeat_namespace               = "monitoring"
    istio_external_ips               = ["172.20.75.75"]
    istio_haproxy_svc_ip             = "172.21.75.75"
    istio_meshid                     = "mesh1"
    istio_network_name               = "ext-net"
    istio_ca_key                     = var.ext_istio_ca_key
    istio_ca_cert                    = "ext-eks/ca-cert.pem"
    istio_cert_chain                 = "ext-eks/cert-chain.pem"
    istio_helloworld_version         = "v2"
    istio_ewgw_load_balancer_type    = "internal"
    istio_ingress_load_balancer_type = "internet-facing"
    istio_root_cert                  = "ext-eks/root-cert.pem"
    istio_remote_pilot_address       = "172.21.75.75"
    istio_service_type               = "NodePort"
    istio_virtual_services = [
      "elasticsearch",
      "logstash"
    ]
    aws_account_id = data.aws_caller_identity.current.account_id
    peer_lb_ips = flatten([
      for mapping in data.aws_lb.int_eks_internal_nlb.subnet_mapping : [
        mapping.private_ipv4_address
      ]
    ])
    lb_dns_name = data.aws_lb.int_eks_internal_nlb.dns_name
    enabled_helm_releases = {
      cert-manager       = true,
      cluster-autoscaler = true,
      elk                = false,
      external-dns       = true,
      filebeat           = true,
      grafana            = false,
      istio              = true,
      istio-base         = true,
      istio_helloworld   = true,
      k8s-auditor        = true,
      kyverno            = true,
      prometheus         = false,
      oauth2-proxy       = false,
    }
    gcp_project                = ""
    github_client_secret       = var.github_client_secret
    github_client_id           = var.github_client_id
    oauth2_proxy_namespace     = "oauth2-proxy"
    oauth2_proxy_cookie_secret = var.oauth2_proxy_cookie_secret
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

  ext_api_endpoint = data.aws_eks_cluster.ext_eks.endpoint
  ext_ca_data      = data.aws_eks_cluster.ext_eks.certificate_authority[0].data
  ext_cluster_name = local.ext_cluster.name

  depends_on = [
    module.int_cluster,
    module.ext_cluster,
  ]
}
