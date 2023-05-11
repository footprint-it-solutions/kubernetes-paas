resource "google_service_account" "external-dns" {
  account_id   = "external-dns"
  display_name = "External DNS Service Account"
}

resource "google_project_iam_binding" "external-dns" {
  project = var.project_id
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.external-dns.email}"
  ]
}

resource "google_service_account_iam_binding" "external-dns" {
  service_account_id = google_service_account.external-dns.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[kube-system/external-dns]"
  ]
}
