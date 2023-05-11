terraform {
  required_providers {
    kubernetes = {
      configuration_aliases = [kubernetes.cluster]
    }
  }
}

resource "kubernetes_namespace" "this" {
  provider = kubernetes.cluster

  for_each = var.namespaces

  metadata {
    labels = each.value.labels
    name   = each.key
  }
}

variable "namespaces" {
  type    = map(any)
  default = {}
}
