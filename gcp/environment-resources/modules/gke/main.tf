resource "google_container_cluster" "this" {
  name               = var.cluster_name
  min_master_version = var.k8s_version

  cluster_autoscaling {
    enabled = true

    resource_limits {
      maximum       = 20
      minimum       = 2
      resource_type = "cpu"
    }

    resource_limits {
      maximum       = 512
      minimum       = 1
      resource_type = "memory"
    }
  }

  initial_node_count = 1

  ip_allocation_policy {
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  location                 = var.region
  network                  = var.network
  remove_default_node_pool = true
  subnetwork               = var.subnetwork

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

# output "kubernetes_cluster_host" {
#   value       = google_container_cluster.int.endpoint
#   description = "GKE Cluster Host"
# }
