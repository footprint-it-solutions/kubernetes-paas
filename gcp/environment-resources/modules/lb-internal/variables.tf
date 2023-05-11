variable "health_check_ids" {
  type = object({
    istio-eastwest-gateway = string
    istio-ingress-gateway  = string
  })
}

variable "instance_group_urls" {
  type = list(any)
}

variable "name" {}
variable "network" {}
variable "region" {}
variable "subnetwork" {}
