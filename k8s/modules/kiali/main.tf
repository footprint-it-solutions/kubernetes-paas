terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "kiali" {
  provider = helm.cluster

  name = "kiali-server"

  chart      = "kiali-server"
  lint       = true
  namespace  = var.namespace
  repository = "https://kiali.org/helm-charts"

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      cluster_name           = var.cluster_name
      custom_docker_registry = var.custom_docker_registry
      domain                 = var.domain
      lb_dns_name            = var.lb_dns_name
    })
  ]
}
