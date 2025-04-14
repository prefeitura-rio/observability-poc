variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "cluster_issuer" {
  type        = string
  nullable    = false
  description = "Cert-manager cluster issuer name"
}

variable "node_pool" {
  type        = string
  nullable    = false
  description = "Node pool name"
}

variable "loki_password" {
  type        = string
  description = "Password for Loki authentication"
  sensitive   = true
}

variable "loki_user" {
  type        = string
  description = "Username for Loki authentication"
}

variable "loki_bucket_name" {
  type        = string
  description = "GCS bucket name for Loki storage"
}

variable "cluster_endpoint" {
  type        = string
  description = "Cluster endpoint"
}

variable "client_certificate" {
  type        = string
  description = "Certificate used by clients to authenticate to the cluster endpoint"
}

variable "client_key" {
  type        = string
  description = "Private key used by clients to authenticate to the cluster endpoint"
}

variable "cluster_ca_certificate" {
  type        = string
  description = "Public certificate that is the root of trust for the cluster"
}

variable "access_token" {
  type        = string
  description = "Access token for authentication"
}

variable "ingress_address" {
  type        = string
  description = "The static IP address for the ingress"
}

variable "k8s_domain" {
  type        = string
  description = "The domain name for the Kubernetes cluster"
}
