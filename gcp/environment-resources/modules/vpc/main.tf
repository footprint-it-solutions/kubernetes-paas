resource "google_compute_firewall" "to-int-from-corp" {
  name = "to-int-from-corp"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "22",
      "80",
      "443"
    ]
  }

  network = google_compute_network.int.name

  source_ranges = [
    "10.10.0.0/24",
    "10.10.1.0/28",
  ]
}

resource "google_compute_firewall" "ext-lb-health-check" {
  name = "ext-lb-health-check"

  allow {
    protocol = "tcp"
    ports = [
      "31021",
      "32021"
    ]
  }

  network = google_compute_network.ext.name

  source_ranges = []
}

resource "google_compute_firewall" "int-lb-health-check" {
  name = "int-lb-health-check"

  allow {
    protocol = "tcp"
    ports = [
      "31021",
      "32021"
    ]
  }

  network = google_compute_network.int.name

  source_ranges = []
}

# Int VPC
resource "google_compute_network" "int" {
  name                    = "int"
  auto_create_subnetworks = "false"
}

# Int Subnet
resource "google_compute_subnetwork" "int" {
  name          = "int"
  region        = var.region
  network       = google_compute_network.int.name
  ip_cidr_range = var.int_vpc_cidr
}

# Ext VPC
resource "google_compute_network" "ext" {
  name                    = "ext"
  auto_create_subnetworks = "false"
}

# Ext Subnet
resource "google_compute_subnetwork" "ext" {
  name          = "ext"
  region        = var.region
  network       = google_compute_network.ext.name
  ip_cidr_range = var.ext_vpc_cidr
}

resource "google_compute_network_peering" "ext-to-int" {
  name         = "ext-to-int"
  network      = google_compute_network.ext.id
  peer_network = google_compute_network.int.id
}

resource "google_compute_network_peering" "int-to-ext" {
  name         = "int-to-ext"
  network      = google_compute_network.int.id
  peer_network = google_compute_network.ext.id
}

output "ids" {
  value = {
    "int"     = google_compute_network.int.id,
    "ext"     = google_compute_network.ext.id,
    "int_sub" = google_compute_subnetwork.int.id,
    "ext_sub" = google_compute_subnetwork.ext.id
  }
}
