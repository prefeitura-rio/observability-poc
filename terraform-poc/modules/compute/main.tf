resource "google_compute_instance" "grafana" {
  name         = "grafana"
  machine_type = var.machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.vpc_subnetwork
    access_config {}
  }

  metadata = {
    ssh-keys = "coreos:${var.ssh_public_key}"
  }

  tags = ["grafana", "monitoring"]
}
