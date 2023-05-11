resource "google_container_node_pool" "this" {
  name               = "${var.cluster_name}-node-pool-${var.machine_type}"
  cluster            = var.cluster_name
  initial_node_count = var.min_count
  location           = var.region
  node_locations     = var.node_locations
  version            = var.k8s_version

  autoscaling {
    min_node_count = var.min_count
    max_node_count = var.max_count
  }

  node_config {

    labels = {
      env = var.cluster_name
    }

    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    preemptible = var.preemptible

    tags = [
      "gke-node",
      var.cluster_name
    ]

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }
}

output "instance_group_urls" {
  value = google_container_node_pool.this.instance_group_urls
}
