variable "chart_version" {
  default = "7.10.2"
  type    = string
}

variable "cluster_name" {
  type = string
}

variable "custom_docker_registry" {
  default = ""
}

variable "namespace" {
  default = "kube-system"
  type    = string
}
