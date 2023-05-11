terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "kyverno" {
  provider = helm.cluster
  name     = "kyverno"

  chart             = "${path.module}/helm/kyverno-custom"
  create_namespace  = true
  lint              = true
  namespace         = var.namespace
  dependency_update = true

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      custom_docker_registry = var.custom_docker_registry
    })
  ]

  wait = true
}

resource "time_sleep" "kyverno" {
  create_duration = "60s"

  depends_on = [
    helm_release.kyverno
  ]
}
