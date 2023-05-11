resource "google_compute_region_health_check" "istio-eastwest-gateway" {
  region = var.region
  name   = "istio-eastwest-gateway"

  tcp_health_check {
    port               = 32021
    port_specification = "USE_FIXED_PORT"
  }
}

resource "google_compute_region_health_check" "istio-ingress-gateway" {
  region = var.region
  name   = "istio-ingress-gateway"

  tcp_health_check {
    port               = 31021
    port_specification = "USE_FIXED_PORT"
  }
}

output "ids" {
  value = {
    "istio-eastwest-gateway" = google_compute_region_health_check.istio-eastwest-gateway.id,
    "istio-ingress-gateway"  = google_compute_region_health_check.istio-ingress-gateway.id
  }
}
