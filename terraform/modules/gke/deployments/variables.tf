variable "cluster_issuer" {
  type        = string
  nullable    = false
  description = "Cert Manager Cluster Issuer name"
}

variable "host" {
  type        = string
  nullable    = false
  description = "Default ingress hostname"
}
