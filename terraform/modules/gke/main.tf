resource "google_compute_address" "poc_k8s" {
  name         = "poc-k8s-address"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_container_cluster" "poc_k8s_cluster" {
  name     = "poc-cluster"
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

resource "google_container_node_pool" "poc_k8s_node_pool" {
  name     = "poc-node-pool"
  cluster  = google_container_cluster.poc_k8s_cluster.name
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
    service_account = var.cluster_service_account
    spot            = false
    machine_type    = var.machine_type.large
    disk_size_gb    = var.disk_size.small
    tags            = ["gke-node"]

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

resource "google_dns_record_set" "poc_k8s_a" {
  name         = "${var.k8s_domain}."
  managed_zone = "dados-rio"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.poc_k8s.address]
}

resource "google_dns_record_set" "poc_k8s_cname" {
  name         = "*.${var.k8s_domain}."
  managed_zone = "dados-rio"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${var.k8s_domain}."]
}

module "deployments" {
  source = "./deployments"

  access_token           = local.access_token
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
  cluster_endpoint       = local.cluster_endpoint
  cluster_issuer         = local.cert_manager_cluster_issuer
  ingress_address        = google_compute_address.poc_k8s.address
  k8s_domain             = var.k8s_domain
  loki_bucket_name       = local.loki_bucket_name
  loki_password          = local.loki_password
  loki_user              = local.loki_user
  node_pool              = local.node_pool.name
  project_id             = var.project_id
}
