resource "google_compute_region_backend_service" "istio-eastwest-gateway" {
  load_balancing_scheme = "INTERNAL"

  dynamic "backend" {
    for_each = var.instance_group_urls

    content {
      balancing_mode = "CONNECTION"
      description    = backend.value["description"]
      group          = replace(backend.value["group"], "instanceGroupManagers", "instanceGroups")
    }
  }

  region      = var.region
  name        = "${var.name}-istio-eastwest-gateway"
  protocol    = "TCP"
  timeout_sec = 10

  health_checks = [
    var.health_check_ids.istio-eastwest-gateway
  ]
}

resource "google_compute_region_backend_service" "istio-ingress-gateway" {
  load_balancing_scheme = "INTERNAL"

  dynamic "backend" {
    for_each = var.instance_group_urls

    content {
      balancing_mode = "CONNECTION"
      description    = backend.value["description"]
      group          = replace(backend.value["group"], "instanceGroupManagers", "instanceGroups")
    }
  }

  region      = var.region
  name        = "${var.name}-istio-ingress-gateway"
  protocol    = "TCP"
  timeout_sec = 10

  health_checks = [
    var.health_check_ids.istio-ingress-gateway
  ]
}

# resource "google_compute_forwarding_rule" "istio-http" {
#   # provider = google-beta
#   name   = "istio-ingress-gateway-http"
#   region = var.region

#   ip_protocol           = "TCP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   port_range            = "80"
#   target                = google_compute_region_target_http_proxy.default.id
#   network               = var.network # google_compute_network.default.id
#   subnetwork            = var.subnetwork # google_compute_subnetwork.default.id
#   network_tier          = "PREMIUM"
# }
