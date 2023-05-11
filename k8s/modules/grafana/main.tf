terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "grafana" {
  provider = helm.cluster
  name     = "grafana"

  chart             = "${path.module}/helm/grafana-custom"
  dependency_update = true
  lint              = true
  namespace         = var.namespace

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      custom_docker_registry = var.custom_docker_registry
      lb_dns_name            = var.lb_dns_name
      domain                 = var.domain
    })
  ]
}
