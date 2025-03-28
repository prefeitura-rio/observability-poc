resource "google_compute_firewall" "allow_ssh_gke" {
  name    = "allow-ssh"
  network = google_compute_network.poc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_router" "poc" {
  name    = "poc"
  network = google_compute_network.poc.name
  region  = var.region

}

resource "google_compute_router_nat" "poc" {
  name                               = "gke-datalake-router-nat"
  router                             = google_compute_router.poc.name
  region                             = google_compute_router.poc.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.poc.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  log_config {
    enable = true
    filter = "ALL"
  }
}

resource "google_compute_network" "poc" {
  name                    = "poc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "poc" {
  name          = "poc"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.poc.id

  secondary_ip_range {
    range_name    = "poc-pods"
    ip_cidr_range = "10.48.0.0/14"
  }

  secondary_ip_range {
    range_name    = "poc-services"
    ip_cidr_range = "10.52.0.0/20"
  }
}
