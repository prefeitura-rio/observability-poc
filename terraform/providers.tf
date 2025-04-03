terraform {
  backend "gcs" {
    prefix = "terraform-poc"
  }
  required_providers {
    infisical = {
      source  = "infisical/infisical"
      version = "0.15.2"
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
