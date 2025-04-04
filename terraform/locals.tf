locals {
  region           = data.infisical_secrets.gke.secrets["REGION"].value
  project_id       = data.infisical_secrets.gke.secrets["PROJECT_ID"].value
  ssh_public_key   = data.infisical_secrets.gke.secrets["VM_SSH_PUBLIC_KEY"].value
  ssh_private_key  = data.infisical_secrets.gke.secrets["VM_SSH_PRIVATE_KEY"].value
  host             = data.infisical_secrets.gke.secrets["HOST"].value
  loki_password    = data.infisical_secrets.gke.secrets["LOKI_PASSWORD"].value
  loki_user        = data.infisical_secrets.gke.secrets["LOKI_USER"].value
  loki_domain      = data.infisical_secrets.gke.secrets["LOKI_DOMAIN"].value
  loki_bucket_name = data.infisical_secrets.gke.secrets["LOKI_BUCKET_NAME"].value
  machine_type = {
    default = "e2-standard-2"
    large   = "e2-standard-4"
  }
  disk_size = {
    small = 20
    large = 50
  }
}
