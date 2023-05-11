terraform {}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "europe-west2-b"
}

resource "google_container_registry" "this" {
  project  = var.project_id
  location = "EU"
}

module "dns" {
  source = "./modules/dns"
}

module "iam" {
  project_id = var.project_id
  source     = "./modules/iam"
}
