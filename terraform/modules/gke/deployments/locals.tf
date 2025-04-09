locals {
  host_without_dot  = replace(var.host, ".", "-")
  loki_domain       = "loki.${var.k8s_domain}"
  prometheus_domain = "prometheus.${var.k8s_domain}"
  gatus_domain      = "gatus.${var.k8s_domain}"
  rrdatas           = ["${var.k8s_domain}."]
}
