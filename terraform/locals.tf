locals {
  region                  = data.infisical_secrets.gke.secrets["REGION"].value
  project_id              = data.infisical_secrets.gke.secrets["PROJECT_ID"].value
  host                    = data.infisical_secrets.gke.secrets["HOST"].value
  cluster_service_account = data.infisical_secrets.gke.secrets["CLUSTER_SERVICE_ACCOUNT"].value
  machine_type = {
    default = "e2-standard-2"
    large   = "e2-standard-4"
  }
  disk_size = {
    small = 20
    large = 50
  }
}
