resource "google_compute_firewall" "allow_ssh_gke" {
  name          = "allow-ssh"
  network       = google_compute_network.poc.name
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_gke_control_plane" {
  name          = "allow-gke-control-plane"
  network       = google_compute_network.poc.name
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
