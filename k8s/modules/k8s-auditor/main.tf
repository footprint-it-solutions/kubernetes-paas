terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "k8s-auditor" {
  provider = helm.cluster
  name     = "k8s-auditor"

  chart     = "${path.module}/helm/k8s-auditor"
  lint      = true
  namespace = var.namespace

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      cluster_name           = var.cluster_name
      custom_docker_registry = var.custom_docker_registry
    })
  ]

  version = "v0.0.2"
  # Has to wait for ES, which takes a while to reach ready state
  wait = false
}
