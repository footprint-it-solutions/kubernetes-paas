terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "elk" {
  provider = helm.cluster
  name     = "elk"

  chart             = "${path.module}/helm/elk-custom"
  dependency_update = true
  lint              = true
  namespace         = var.namespace
  repository        = "https://helm.elastic.co"
  timeout           = 900 # longer timeout

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      custom_docker_registry = var.custom_docker_registry
      domain                 = var.domain
      es_version             = var.es_version
      kibana_version         = var.kibana_version
      logstash_version       = var.logstash_version
      lb_dns_name            = var.lb_dns_name
    })
  ]

  # Don't wait for ELK as spinning up the nodes takes a while...
  wait = false
}
