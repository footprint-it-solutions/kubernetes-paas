variable "region" {
  default = "europe-west2"
}

variable "project_id" {
  default = "YOUR_GCP_PROJECT"
}

variable "k8s_version_prefix" {
  type    = string
  default = "1.19."
}

variable "ext_gke_nodepools" {
  description = "Object containing the GKE nodepools"
  default     = {}
  type        = map(any)
}

variable "int_gke_nodepools" {
  description = "Object containing the GKE nodepools"
  default     = {}
  type        = map(any)
}

variable "ext_vpc_cidr" {
  default = "10.10.28.0/22"
}

variable "int_vpc_cidr" {
  default = "10.10.24.0/22"
}

variable "gke_node_locations" {
  default = [
    "europe-west2-a",
    "europe-west2-b",
    "europe-west2-c"
  ]
  type = set(string)
}

variable "peer_ip" {
  default = "YOUR_PUBLIC_IP"
}

variable "shared_secret" {
  description = "The pre-shared key for tunnel 1"
}
