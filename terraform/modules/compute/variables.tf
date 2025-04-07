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
  type        = string
  description = "The machine type for the instance"
}

variable "disk_size" {
  type        = number
  description = "The disk size in GB"
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key content for the instance"
}

variable "ssh_private_key" {
  type        = string
  description = "Path to the SSH private key file"
}
