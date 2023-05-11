int_gke_nodepools = {
  "infra-co-c2-standard-4" = {
    machine_type = "c2-standard-4"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-co-c2-standard-8" = {
    machine_type = "c2-standard-8"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-gp-n2-standard-2" = {
    machine_type = "n2-standard-2"
    max_count    = 3
    min_count    = 1
    preemptible  = true
  },
  "infra-gp-n2d-standard-2" = {
    machine_type = "n2d-standard-2"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-gp-n2-standard-4" = {
    machine_type = "n2-standard-4"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-gp-n2d-standard-4" = {
    machine_type = "n2d-standard-4"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-mo-m1-ultramem-40-ew2bc" = {
    machine_type   = "m1-ultramem-40"
    max_count      = 3
    min_count      = 0
    node_locations = "europe-west2-b,europe-west2-c"
    preemptible    = true
  }
}

ext_gke_nodepools = {
  "infra-co-c2-standard-4" = {
    machine_type = "c2-standard-4"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-co-c2-standard-8" = {
    machine_type = "c2-standard-8"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-gp-n2-standard-2" = {
    machine_type = "n2-standard-2"
    max_count    = 3
    min_count    = 1
    preemptible  = true
  },
  "infra-gp-n2d-standard-2" = {
    machine_type = "n2d-standard-2"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-gp-n2-standard-4" = {
    machine_type = "n2-standard-4"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-gp-n2d-standard-4" = {
    machine_type = "n2d-standard-4"
    max_count    = 3
    min_count    = 0
    preemptible  = true
  },
  "infra-mo-m1-ultramem-40-ew2bc" = {
    machine_type   = "m1-ultramem-40"
    max_count      = 3
    min_count      = 0
    node_locations = "europe-west2-b,europe-west2-c"
    preemptible    = true
  }
}
