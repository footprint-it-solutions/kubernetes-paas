resource "google_dns_managed_zone" "gcp-fmlabs-xyz" {
  name        = "gcp-fmlabs-xyz"
  dns_name    = "gcp.your.domain."
  description = "DNS zone"
}
