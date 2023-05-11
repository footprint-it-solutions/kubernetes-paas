module "int" {
  source  = "GoogleCloudPlatform/lb-internal/google"
  version = "~> 2.0"
  region  = var.region
  name    = "int"
  ports   = ["80"]
  health_check = {
    type                = "http"
    check_interval_sec  = 1
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 8081
    port_name           = "health-check-port"
    request             = ""
    request_path        = "/"
    host                = "1.2.3.4"
    enable_log          = false
  }
  source_tags = ["allow-group1"]
  target_tags = ["allow-group2", "allow-group3"]

  backends = [
    for pool in var.int_gke_nodepools :
    [
      for url in module.int_gke_nodepool[pool].instance_group_urls :
      { group = url, description = pool }
    ]
  ]
}
