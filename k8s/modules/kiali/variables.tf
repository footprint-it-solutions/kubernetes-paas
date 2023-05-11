variable "cluster_name" {}

variable "custom_docker_registry" {
  default = ""
}

variable "domain" {}

variable "lb_dns_name" {}

variable "namespace" {
  default = "istio-system"
}
