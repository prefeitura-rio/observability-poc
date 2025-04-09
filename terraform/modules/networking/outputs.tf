output "vpc_network" {
  value = google_compute_network.poc_network.name
}

output "vpc_subnetwork" {
  value = google_compute_subnetwork.poc_subnet.name
}
