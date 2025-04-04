module "networking" {
  source = "./modules/networking"

  project_id = local.project_id
  region     = local.region
}

module "gke" {
  source = "./modules/gke"

  project_id       = local.project_id
  region           = local.region
  vpc_network      = module.networking.vpc_network_name
  vpc_subnetwork   = module.networking.vpc_subnetwork_name
  machine_type     = local.machine_type
  disk_size        = local.disk_size
  host             = local.host
  loki_password    = local.loki_password
  loki_user        = local.loki_user
  loki_domain      = local.loki_domain
  loki_bucket_name = local.loki_bucket_name
}

module "compute" {
  source = "./modules/compute"

  project_id      = local.project_id
  region          = local.region
  vpc_network     = module.networking.vpc_network_name
  vpc_subnetwork  = module.networking.vpc_subnetwork_name
  machine_type    = local.machine_type.default
  disk_size       = local.disk_size.large
  ssh_public_key  = local.ssh_public_key
  ssh_private_key = local.ssh_private_key
}
