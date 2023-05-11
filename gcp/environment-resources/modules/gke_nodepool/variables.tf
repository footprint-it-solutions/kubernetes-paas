variable "region" {
  default = "europe-west2"
}

variable "cluster_name" {}

variable "k8s_version" {}

variable "machine_type" {}

variable "max_count" {}

variable "min_count" {}

variable "node_locations" {
  type = set(string)
}

variable "preemptible" {
  default = true
}
