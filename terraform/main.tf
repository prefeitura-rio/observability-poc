module "networking" {
  source = "./modules/networking"

  project_id = local.project_id
  region     = local.region
}

module "gke" {
  source = "./modules/gke"

  cluster_service_account = local.cluster_service_account
  disk_size               = local.disk_size
  k8s_domain              = local.k8s_domain
  machine_type            = local.machine_type
  project_id              = local.project_id
  region                  = local.region
  vault                   = data.infisical_secrets.gke.secrets
  vpc_network             = module.networking.vpc_network
  vpc_subnetwork          = module.networking.vpc_subnetwork
}

module "compute" {
  source = "./modules/compute"

  disk_size      = local.disk_size.large
  machine_type   = local.machine_type.default
  project_id     = local.project_id
  region         = local.region
  vm_domain      = local.vm_domain
  vpc_network    = module.networking.vpc_network
  vpc_subnetwork = module.networking.vpc_subnetwork
}
