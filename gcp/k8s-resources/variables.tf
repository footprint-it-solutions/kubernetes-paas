variable "custom_docker_registry" {
  default = "eu.gcr.io/YOUR_GCP_PROJECT"
}

variable "region" {
  default = "europe-west2"
}

variable "project_id" {
  default = "YOUR_GCP_PROJECT"
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
