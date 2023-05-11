terraform {
  required_providers {
    kubernetes = {
      configuration_aliases = [kubernetes.cluster]
    }
  }
}

data "kubernetes_service" "istio-eastwestgateway" {
  provider = kubernetes.cluster

  metadata {
    name      = "istio-eastwestgateway"
    namespace = "istio-system"
  }
}

output "resources" {
  value = {
    istio_eastwestgateway_service = data.kubernetes_service.istio-eastwestgateway
  }
}
