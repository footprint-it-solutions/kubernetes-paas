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

resource "kubernetes_priority_class" "filebeat" {
  metadata {
    annotations = {}
    labels      = {}
    name        = "filebeat"
  }

  provider = kubernetes.cluster

  value = 1000000000
}

resource "helm_release" "filebeat" {
  provider = helm.cluster
  name     = "filebeat"

  chart      = "filebeat"
  lint       = true
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  timeout    = 420 # longer timeout

  values = [
    templatefile("${path.module}/helm/filebeat-values.yaml", {
      chart_version          = var.chart_version
      cluster_name           = var.cluster_name
      custom_docker_registry = var.custom_docker_registry
      namespace              = var.namespace
      priority_class_name    = kubernetes_priority_class.filebeat.id
    })
  ]

  version = var.chart_version
  # Do not wait for filebeat in the external cluster,
  # as it depends on the Istio service mesh secrets
  wait = length(regexall("ext", var.cluster_name)) > 0 ? false : true
}
