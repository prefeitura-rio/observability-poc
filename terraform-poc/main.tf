terraform {
  backend "gcs" {
    prefix = "terraform-poc"
  }
  required_providers {
    infisical = {
      source = "infisical/infisical"
    }
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}

provider "infisical" {
  host          = var.infisical_address
  service_token = var.infisical_token
}

data "infisical_secrets" "gke" {
  env_slug    = var.infisical_profile
  folder_path = var.infisical_path
}

provider "google" {
  project = data.infisical_secrets.gke.secrets["PROJECT_ID"].value
  region  = data.infisical_secrets.gke.secrets["REGION"].value
}

data "terraform_remote_state" "project_id" {
  backend   = "gcs"
  workspace = terraform.workspace

  config = {
    bucket = data.infisical_secrets.gke.secrets["BUCKET_NAME"].value
    prefix = "terraform-state"
  }
}

resource "google_container_cluster" "observability_poc" {
  name                     = "observability-poc"
  location                 = data.infisical_secrets.gke.secrets["REGION"].value
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = "default"
  subnetwork               = "default"

  workload_identity_config {
    workload_pool = "${data.infisical_secrets.gke.secrets["PROJECT_ID"].value}.svc.id.goog"
  }

  network_policy {
    enabled = true
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.observability_poc.name
  location   = data.infisical_secrets.gke.secrets["REGION"].value
  node_count = 3

  node_config {
    machine_type = "e2-standard-2"
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}

resource "google_compute_instance" "grafana" {
  name         = "grafana"
  machine_type = "e2-standard-2"
  zone         = "${data.infisical_secrets.gke.secrets["REGION"].value}-a"

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {
      # ephemeral public IP
    }
  }

  # metadata = {
  #   ssh-keys = "coreos:${data.infisical_secrets.gke.secrets["SSH_PUBLIC_KEY"].value}"
  # }

  tags = ["grafana", "monitoring"]
}

resource "google_compute_firewall" "grafana" {
  name    = "allow-grafana"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["grafana"]
}
