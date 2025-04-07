terraform {
  required_version = ">= 1.11.0"

  backend "gcs" {
    prefix = "terraform-poc"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.28.0"
    }
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
