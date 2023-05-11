terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "cert-manager" {
  provider = helm.cluster
  name     = "cert-manager"

  chart            = "cert-manager"
  create_namespace = true
  lint             = true
  namespace        = var.namespace
  repository       = "https://charts.jetstack.io"

  set {
    name  = "installCRDs"
    value = "true"
  }
  values = [
    templatefile("${path.module}/helm/cert-manager-custom/values.yaml", {
      cluster_name           = var.cluster_name
      custom_docker_registry = var.custom_docker_registry
    })
  ]

  version = "v1.3.1"
}
