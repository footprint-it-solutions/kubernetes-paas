terraform {}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "europe-west2-b"
}

data "google_project" "this" {}

module "vpc" {
  source       = "./modules/vpc"
  project_name = data.google_project.this.name
  int_vpc_cidr = var.int_vpc_cidr
  ext_vpc_cidr = var.ext_vpc_cidr
  region       = var.region
}

data "google_container_engine_versions" "supported" {
  version_prefix = var.k8s_version_prefix
}
module "ext_gke" {
  source = "./modules/gke"

  cluster_name             = "ext-gke"
  k8s_version              = data.google_container_engine_versions.supported.release_channel_default_version.STABLE
  network                  = "ext"
  project_id               = var.project_id
  project_name             = data.google_project.this.name
  region                   = var.region
  services_ipv4_cidr_block = "172.21.0.0/16"
  subnetwork               = "ext"

  depends_on = [
    module.vpc
  ]
}

module "ext_gke_nodepool" {
  for_each = var.ext_gke_nodepools
  source   = "./modules/gke_nodepool"

  cluster_name       = "ext-gke"
  k8s_version        = data.google_container_engine_versions.supported.release_channel_default_version.STABLE
  machine_type       = each.value.machine_type
  max_count          = each.value.max_count
  min_count          = each.value.min_count
  node_locations     = can(each.value.node_locations) ? split(",", each.value.node_locations) : var.gke_node_locations
  preemptible        = each.value.preemptible

  depends_on = [
    module.ext_gke
  ]
}

module "int_gke" {
  source = "./modules/gke"

  cluster_name             = "int-gke"
  k8s_version              = data.google_container_engine_versions.supported.release_channel_default_version.STABLE
  network                  = "int"
  project_id               = var.project_id
  project_name             = data.google_project.this.name
  region                   = var.region
  services_ipv4_cidr_block = "172.20.0.0/16"
  subnetwork               = "int"

  depends_on = [
    module.vpc
  ]
}

module "int_gke_nodepool" {
  for_each = var.int_gke_nodepools
  source   = "./modules/gke_nodepool"

  cluster_name       = "int-gke"
  k8s_version        = data.google_container_engine_versions.supported.release_channel_default_version.STABLE
  machine_type       = each.value.machine_type
  max_count          = each.value.max_count
  min_count          = each.value.min_count
  node_locations     = can(each.value.node_locations) ? split(",", each.value.node_locations) : var.gke_node_locations
  preemptible        = each.value.preemptible

  depends_on = [
    module.int_gke
  ]
}

module "ipsec" {
  managed_zone  = "YOUR_MANAGED_ZONE"
  peer_ip       = var.peer_ip
  shared_secret = var.shared_secret
  source        = "./modules/ipsec"
  vpc_id        = module.vpc.ids.int
}

