terraform {
  backend "gcs" {
    prefix = "terraform-poc"
  }
  required_providers {
    infisical = {
      source = "infisical/infisical"
    }
  }
}

provider "infisical" {
  host          = var.infisical_address
  service_token = var.infisical_token
}

provider "google" {
  project = local.project_id
  region  = local.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(module.gke.client_certificate)
  client_key             = base64decode(module.gke.client_key)
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.cluster_endpoint}"
    token                  = data.google_client_config.current.access_token
    client_certificate     = base64decode(module.gke.client_certificate)
    client_key             = base64decode(module.gke.client_key)
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  }
}
