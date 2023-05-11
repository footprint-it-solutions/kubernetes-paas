terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
    kubernetes = {
      configuration_aliases = [kubernetes.cluster]
    }
  }
}

module "shared_namespaces" {
  source     = "./modules/namespaces"
  namespaces = var.cluster.shared_namespaces

  providers = {
    kubernetes.cluster = kubernetes.cluster
  }
}

module "kyverno" {
  source = "./modules/kyverno"
  count  = var.cluster.enabled_helm_releases.kyverno ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  custom_docker_registry = var.cluster.custom_docker_registry
  namespace              = var.cluster.kyverno_namespace
}

module "cluster-autoscaler" {
  source = "./modules/cluster-autoscaler"
  count  = var.cluster.enabled_helm_releases.cluster-autoscaler ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  depends_on = [
    module.kyverno
  ]

  aws_account            = var.cluster.aws_account_id
  cluster_name           = var.cluster.name
  custom_docker_registry = var.cluster.custom_docker_registry
  region                 = var.cluster.region
}

module "external-dns" {
  source = "./modules/external-dns"
  count  = var.cluster.enabled_helm_releases.external-dns ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  depends_on = [
    module.kyverno
  ]

  aws_account            = var.cluster.aws_account_id
  cluster_name           = var.cluster.name
  custom_docker_registry = var.cluster.custom_docker_registry
  domainzones            = var.cluster.domainzones
  gcp_project            = var.cluster.gcp_project
  region                 = var.cluster.region
}

module "prometheus" {
  source = "./modules/prometheus"
  count  = var.cluster.enabled_helm_releases.prometheus ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  depends_on = [
    module.istio,
    module.kyverno,
    module.shared_namespaces
  ]
  custom_docker_registry = var.cluster.custom_docker_registry
  namespace              = var.cluster.prometheus_namespace
}

module "grafana" {
  source = "./modules/grafana"
  count  = var.cluster.enabled_helm_releases.grafana ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  depends_on = [
    module.kyverno,
    module.shared_namespaces
  ]
  custom_docker_registry = var.cluster.custom_docker_registry
  lb_dns_name            = var.cluster.lb_dns_name
  domain                 = var.cluster.domain
  namespace              = var.cluster.grafana_namespace
}

module "cert-manager" {
  source = "./modules/cert-manager"
  count  = var.cluster.enabled_helm_releases.cert-manager ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  depends_on = [
    module.kyverno
  ]

  cluster_name           = var.cluster.name
  custom_docker_registry = var.cluster.custom_docker_registry
  namespace              = var.cluster.certmanager_namespace
}

module "istio" {
  source = "./modules/istio"
  count  = var.cluster.enabled_helm_releases.istio ? 1 : 0
  providers = {
    kubernetes.cluster = kubernetes.cluster,
    helm.cluster       = helm.cluster
  }
  depends_on = [
    module.istio-base,
    module.kyverno
  ]

  cluster_name            = var.cluster.name
  custom_docker_registry  = var.cluster.custom_docker_registry
  ewgwLoadBalancerType    = var.cluster.istio_ewgw_load_balancer_type
  externalIPs             = var.cluster.istio_external_ips
  haproxyServiceIP        = var.cluster.istio_haproxy_svc_ip
  ingressLoadBalancerType = var.cluster.istio_ingress_load_balancer_type
  meshId                  = var.cluster.istio_meshid
  networkName             = var.cluster.istio_network_name
  istio_ca_key            = var.cluster.istio_ca_key
  istio_ca_cert           = var.cluster.istio_ca_cert
  istio_cert_chain        = var.cluster.istio_cert_chain
  istio_root_cert         = var.cluster.istio_root_cert
  peer_lb_ips             = var.cluster.peer_lb_ips
  remotePilotAddress      = var.cluster.istio_remote_pilot_address
  serviceType             = var.cluster.istio_service_type
  virtual_services        = var.cluster.istio_virtual_services
  oauth2_proxy_enabled    = var.cluster.oauth2_proxy_enabled
  domain                  = var.cluster.domain
}

module "istio-base" {
  source = "./modules/istio-base"
  count  = var.cluster.enabled_helm_releases.istio-base ? 1 : 0

  providers = {
    kubernetes.cluster = kubernetes.cluster,
    helm.cluster       = helm.cluster
  }
  depends_on = [
    module.kyverno
  ]

  custom_docker_registry = var.cluster.custom_docker_registry
  networkName            = var.cluster.istio_network_name
  remotePilotAddress     = var.cluster.istio_remote_pilot_address
}

module "istio_helloworld" {
  source = "./modules/istio-helloworld"
  count  = var.cluster.enabled_helm_releases.istio_helloworld ? 1 : 0
  providers = {
    kubernetes.cluster = kubernetes.cluster
    helm.cluster       = helm.cluster
  }
  depends_on = [
    module.istio,
    module.kyverno
  ]
  custom_docker_registry = var.cluster.custom_docker_registry
  helloworld_version     = var.cluster.istio_helloworld_version
}

module "kiali" {
  source = "./modules/kiali"
  count  = var.cluster.enabled_helm_releases.istio ? 1 : 0

  cluster_name           = var.cluster.name
  custom_docker_registry = var.cluster.custom_docker_registry
  domain                 = var.cluster.domain
  lb_dns_name            = var.cluster.lb_dns_name

  providers = {
    helm.cluster = helm.cluster
  }

  depends_on = [
    module.kyverno
  ]
}

module "elk" {
  source = "./modules/elk"
  count  = var.cluster.enabled_helm_releases.elk ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
  }
  depends_on = [
    module.istio,
    module.kyverno
  ]
  custom_docker_registry = var.cluster.custom_docker_registry
  lb_dns_name            = var.cluster.lb_dns_name
  domain                 = var.cluster.domain
  namespace              = var.cluster.elk_namespace
}

module "filebeat" {
  source = "./modules/filebeat"
  count  = var.cluster.enabled_helm_releases.filebeat ? 1 : 0
  providers = {
    helm.cluster = helm.cluster
    kubernetes.cluster = kubernetes.cluster
  }
  depends_on = [
    module.istio,
    module.kyverno
  ]

  cluster_name           = var.cluster.name
  custom_docker_registry = var.cluster.custom_docker_registry
  namespace              = var.cluster.filebeat_namespace
}

module "k8s-auditor" {
  source = "./modules/k8s-auditor"
  count  = var.cluster.enabled_helm_releases.k8s-auditor ? 1 : 0

  cluster_name           = var.cluster.name
  custom_docker_registry = var.cluster.custom_docker_registry

  depends_on = [
    module.kyverno,
    module.elk
  ]

  namespace = "monitoring"

  providers = {
    helm.cluster = helm.cluster
  }
}


module "oauth2-proxy" {
  source = "./modules/oauth2-proxy"
  count  = var.cluster.enabled_helm_releases.oauth2-proxy ? 1 : 0

  cluster_name               = var.cluster.name
  custom_docker_registry     = var.cluster.custom_docker_registry
  namespace                  = var.cluster.oauth2_proxy_namespace
  lb_dns_name                = var.cluster.lb_dns_name
  domain                     = var.cluster.domain
  github_client_secret       = var.cluster.github_client_secret
  github_client_id           = var.cluster.github_client_id
  oauth2_proxy_cookie_secret = var.cluster.oauth2_proxy_cookie_secret

  providers = {
    helm.cluster = helm.cluster
  }
}
