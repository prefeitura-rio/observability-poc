resource "google_compute_address" "poc" {
  name         = "poc"
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
      nat_ip = google_compute_address.poc.address
    }
  }

  metadata = {
    ssh-keys = "poc:${var.ssh_public_key}"
  }

  connection {
    type        = "ssh"
    user        = "poc"
    private_key = var.ssh_private_key
    host        = google_compute_address.poc.address
  }

  provisioner "file" {
    source      = "./ansible/playbook.yaml"
    destination = "~/poc/playbook.yaml"
  }

  provisioner "file" {
    source      = "./ansible/requirements.yaml"
    destination = "~/poc/requirements.yaml"
  }

  provisioner "file" {
    source      = "./docker/docker-compose.yaml"
    destination = "~/poc/docker-compose.yaml"
  }

  provisioner "file" {
    source      = "./docker/gatus.yaml"
    destination = "~/poc/gatus.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3 python3-pip",
      "sudo pip3 install ansible",
      "ansible-galaxy install -r ~/poc/requirements.yaml",
      "ansible-playbook ~/observability/playbook.yaml"
    ]
  }

  tags = ["observability"]
}
