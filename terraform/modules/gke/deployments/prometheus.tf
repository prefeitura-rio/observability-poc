locals {
  prometheus_domain     = "prometheus.${var.k8s_domain}"
  prometheus_tls_secret = replace("${local.prometheus_domain}-tls", ".", "-")
  prometheus            = "prometheus-prometheus.prometheus.svc.cluster.local"
}

resource "helm_release" "prometheus" {
  depends_on = [
    var.node_pool,
    helm_release.cert_manager,
    helm_release.ingress_nginx,
  ]

  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "70.4.1"
  namespace        = "prometheus"
  create_namespace = true
  values = [templatefile("${path.module}/values/prometheus.yaml", {
    issuer            = var.cluster_issuer
    domain            = local.prometheus_domain
    domain_tls_secret = local.prometheus_tls_secret
    url               = local.prometheus
  })]
}
