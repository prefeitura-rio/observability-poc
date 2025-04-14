resource "google_compute_address" "poc_vm" {
  name         = "poc-vm"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_service_account" "traefik" {
  account_id   = "traefik-poc"
  display_name = "traefik-poc"
  project      = var.project_id
}

resource "google_project_iam_custom_role" "traefik" {
  role_id     = "traefik"
  title       = "Traefik DNS Manager"
  description = "Custom role for Traefik DNS management"
  permissions = [
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.list"
  ]
}

resource "google_project_iam_member" "traefik" {
  project = var.project_id
  role    = google_project_iam_custom_role.traefik.id
  member  = "serviceAccount:${google_service_account.traefik.email}"
}

resource "google_service_account_key" "traefik" {
  service_account_id = google_service_account.traefik.name
}

resource "google_compute_instance" "poc" {
  name         = "poc"
  machine_type = var.machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
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

  metadata_startup_script = templatefile("${path.module}/scripts/init_vm.sh", {
    service_account_email = google_service_account.traefik.email
    service_account_key   = base64decode(google_service_account_key.traefik.private_key)
    gce_project           = var.project_id
  })
}

resource "google_dns_record_set" "poc_vm_a" {
  name         = "${var.vm_domain}."
  managed_zone = "dados-rio"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.poc_vm.address]
}

resource "google_dns_record_set" "poc_vm_cname" {
  name         = "*.${var.vm_domain}."
  managed_zone = "dados-rio"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${var.vm_domain}."]
}
