locals {
  access_token                = data.google_client_config.poc.access_token
  cert_manager_cluster_issuer = "letsencrypt"
  client_certificate          = base64decode(google_container_cluster.poc.master_auth[0].client_certificate)
  client_key                  = base64decode(google_container_cluster.poc.master_auth[0].client_key)
  cluster_ca_certificate      = base64decode(google_container_cluster.poc.master_auth[0].cluster_ca_certificate)
  cluster_endpoint            = google_container_cluster.poc.endpoint
  gatus_k8s_domain            = var.vault["GATUS_K8S_DOMAIN"].value
  loki_bucket_name            = var.vault["LOKI_BUCKET_NAME"].value
  loki_k8s_domain             = var.vault["LOKI_K8S_DOMAIN"].value
  loki_password               = var.vault["LOKI_PASSWORD"].value
  loki_user                   = var.vault["LOKI_USER"].value
  node_pool                   = google_container_node_pool.poc
  prometheus_k8s_domain       = var.vault["PROMETHEUS_K8S_DOMAIN"].value
}
