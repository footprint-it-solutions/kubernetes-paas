terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "external_dns" {
  provider = helm.cluster
  name     = "external-dns"

  chart      = "external-dns"
  lint       = true
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      custom_docker_registry = var.custom_docker_registry
      region                 = var.region
      gcp_project            = var.gcp_project
      cluster_name           = var.cluster_name
      aws_account            = var.aws_account
      domainFilters          = "[${join(",", var.domainzones)}]"
    })
  ]

}

variable "aws_account" {
  default = ""
}
variable "cluster_name" {
  default = ""
}
variable "custom_docker_registry" {
  default = ""
}
variable "domainzones" {}
variable "gcp_project" {
  default = ""
}
variable "region" {
  default = ""
}
