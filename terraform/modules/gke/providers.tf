terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.poc.endpoint}"
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(google_container_cluster.poc.master_auth[0].client_certificate)
  client_key             = base64decode(google_container_cluster.poc.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.poc.master_auth[0].cluster_ca_certificate)
}

provider "kubectl" {
  host                   = "https://${google_container_cluster.poc.endpoint}"
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(google_container_cluster.poc.master_auth[0].client_certificate)
  client_key             = base64decode(google_container_cluster.poc.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.poc.master_auth[0].cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.poc.endpoint}"
    token                  = data.google_client_config.current.access_token
    client_certificate     = base64decode(google_container_cluster.poc.master_auth[0].client_certificate)
    client_key             = base64decode(google_container_cluster.poc.master_auth[0].client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.poc.master_auth[0].cluster_ca_certificate)
  }
}
