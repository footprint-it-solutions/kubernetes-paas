terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "oauth2-proxy" {
  provider = helm.cluster

  name = "oauth2-proxy"

  chart      = "oauth2-proxy"
  lint       = true
  namespace  = var.namespace
  repository = "https://oauth2-proxy.github.io/manifests"

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      cluster_name           = var.cluster_name
      custom_docker_registry = var.custom_docker_registry
      lb_dns_name            = var.lb_dns_name
      client_secret          = var.github_client_secret
      client_id              = var.github_client_id
      cookie_secret          = var.oauth2_proxy_cookie_secret
      domain                 = var.domain
    })
  ]
}
