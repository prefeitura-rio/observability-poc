variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "vpc_network" {
  type        = string
  description = "The name of the VPC network"
}

variable "vpc_subnetwork" {
  type        = string
  description = "The name of the VPC subnetwork"
}

variable "machine_type" {
  type = object({
    default = string
    large   = string
  })
  description = "Machine type configurations"
}

variable "disk_size" {
  type = object({
    small = number
    large = number
  })
  description = "Disk size configurations"
}

variable "host" {
  type        = string
  nullable    = false
  description = "Default ingress hostname"
}

