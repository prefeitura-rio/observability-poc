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
