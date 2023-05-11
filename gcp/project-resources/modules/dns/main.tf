resource "google_dns_managed_zone" "gcp-your-domain" {
  name        = "gcp-your-domain"
  dns_name    = "gcp.your.domain."
  description = "DNS zone"
}
