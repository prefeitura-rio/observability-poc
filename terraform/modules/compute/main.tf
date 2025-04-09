resource "google_compute_address" "poc_vm" {
  name         = "poc-vm"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "poc" {
  name         = "poc"
  machine_type = var.machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.vpc_subnetwork

    access_config {
      nat_ip = google_compute_address.poc_vm.address
    }
  }

  metadata_startup_script = file("${path.module}/scripts/init_vm.sh")

  tags = ["observability"]
}

resource "google_dns_record_set" "poc_vm_a" {
  name         = "poc-vm.dados.rio."
  managed_zone = "dados-rio"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.poc_vm.address]
}

resource "google_dns_record_set" "poc_vm_cname" {
  name         = "*.poc-vm.dados.rio."
  managed_zone = "dados-rio"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["poc-vm.dados.rio."]
}
