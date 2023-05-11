resource "google_dns_record_set" "this" {
  managed_zone = var.managed_zone
  name         = "YOUR_VPN_ENDPOINT_IP."
  rrdatas = [
    google_compute_address.vpn_static_ip.address
  ]
  ttl  = 300
  type = "A"
}

resource "google_compute_vpn_tunnel" "int-to-on-prem" {
  ike_version            = 2
  local_traffic_selector = toset(["10.10.24.0/22"])
  name                   = "int-to-on-prem"
  peer_ip                = var.peer_ip
  remote_traffic_selector = toset([
    "10.10.0.0/24",
    "10.10.1.0/28",
  ])
  shared_secret = var.shared_secret

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500,
  ]
}

resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "int-to-on-prem"
  network = var.vpc_id
}

resource "google_compute_address" "vpn_static_ip" {
  name = "vpn-static-ip"
}

resource "google_compute_forwarding_rule" "esp" {
  name        = "esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "udp500" {
  name        = "udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "udp4500" {
  name        = "udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_route" "int-to-corp" {
  name       = "int-to-corp"
  network    = var.vpc_id
  dest_range = "10.10.0.0/24"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.int-to-on-prem.id
}

resource "google_compute_route" "int-to-wg" {
  name       = "int-to-wg"
  network    = var.vpc_id
  dest_range = "10.10.1.0/28"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.int-to-on-prem.id
}
