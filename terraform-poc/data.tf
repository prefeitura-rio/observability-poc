data "infisical_secrets" "gke" {
  env_slug    = var.infisical_profile
  folder_path = var.infisical_path
}

data "google_client_config" "current" {}

data "terraform_remote_state" "project_id" {
  backend   = "gcs"
  workspace = terraform.workspace

  config = {
    bucket = var.bucket
    prefix = "terraform-state"
  }
}
