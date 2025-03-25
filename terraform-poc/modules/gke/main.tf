resource "google_container_cluster" "poc" {
  name     = "poc"
  location = var.region

  initial_node_count       = 1
  remove_default_node_pool = true
  network                  = var.vpc_network
  subnetwork               = var.vpc_subnetwork
  deletion_protection      = false
  networking_mode          = "VPC_NATIVE"
  datapath_provider        = "ADVANCED_DATAPATH"

  release_channel {
    channel = "RAPID"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.30.0.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "poc-pods"
    services_secondary_range_name = "poc-services"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "External Control Plane access"
    }
  }

  monitoring_config {
    advanced_datapath_observability_config {
      enable_metrics = true
      enable_relay   = true
    }
    enable_components = ["SYSTEM_COMPONENTS", "DCGM", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER", "STORAGE"]
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS"
    ]
  }

  addons_config {
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }
}

resource "google_container_node_pool" "poc" {
  name     = "poc"
  cluster  = google_container_cluster.poc.name
  location = var.region

  upgrade_settings {
    max_surge       = 3
    max_unavailable = 1
  }

  autoscaling {
    total_max_node_count = 6
    total_min_node_count = 1
  }

  node_locations = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]

  node_config {
    service_account = "log-gke@rj-sms.iam.gserviceaccount.com"
    spot            = false
    machine_type    = var.machine_type.default
    disk_size_gb    = var.disk_size.small

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      "disable-legacy-endpoints" = true
    }
  }
}
