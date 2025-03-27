output "vpc_network_name" {
  value = google_compute_network.poc.name
}

output "vpc_subnetwork_name" {
  value = google_compute_subnetwork.poc.name
}
