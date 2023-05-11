terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "prometheus" {
  provider = helm.cluster
  name     = "prometheus-operator"

  chart      = "kube-prometheus"
  lint       = true
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  timeout    = 900 # longer timeout

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      custom_docker_registry = var.custom_docker_registry
    })
  ]
}
