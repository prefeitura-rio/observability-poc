locals {
  access_token                = data.google_client_config.poc.access_token
  cert_manager_cluster_issuer = "letsencrypt"
  client_certificate          = base64decode(google_container_cluster.poc_k8s_cluster.master_auth[0].client_certificate)
  client_key                  = base64decode(google_container_cluster.poc_k8s_cluster.master_auth[0].client_key)
  cluster_ca_certificate      = base64decode(google_container_cluster.poc_k8s_cluster.master_auth[0].cluster_ca_certificate)
  cluster_endpoint            = google_container_cluster.poc_k8s_cluster.endpoint
  loki_bucket_name            = var.vault["LOKI_BUCKET_NAME"].value
  loki_password               = var.vault["LOKI_PASSWORD"].value
  loki_user                   = var.vault["LOKI_USER"].value
  node_pool                   = google_container_node_pool.poc_k8s_node_pool
  k8s_domain                  = "poc-k8s.dados.rio"
}
