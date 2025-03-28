output "cluster_endpoint" {
  value = google_container_cluster.poc.endpoint
}

output "client_certificate" {
  value = google_container_cluster.poc.master_auth[0].client_certificate
}

output "client_key" {
  value = google_container_cluster.poc.master_auth[0].client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.poc.master_auth[0].cluster_ca_certificate
}

output "node_pool" {
  value = google_container_node_pool.poc
}
