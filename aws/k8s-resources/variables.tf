variable "custom_docker_registry" {
  default = "AWS_ACCOUNT_NUMBER.dkr.ecr.eu-west-1.amazonaws.com"
}

variable "region" {
  default = "eu-west-1"
}

variable "ext_istio_ca_key" {
  description = "Private key for Istio CA, essential for multicluster"
}
variable "int_istio_ca_key" {
  description = "Private key for Istio CA, essential for multicluster"
}

variable "github_client_secret" {}
variable "github_client_id" {}
variable "oauth2_proxy_cookie_secret" {}
