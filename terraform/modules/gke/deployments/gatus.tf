locals {
  gatus_domain     = "gatus.${var.k8s_domain}"
  gatus_tls_secret = replace("${local.gatus_domain}-tls", ".", "-")
}

resource "helm_release" "gatus" {
  depends_on = [
    var.node_pool,
    helm_release.cert_manager,
    helm_release.ingress_nginx,
  ]

  name             = "gatus"
  repository       = "https://twin.github.io/helm-charts"
  chart            = "gatus"
  version          = "1.2.0"
  namespace        = "gatus"
  create_namespace = true
  values = [templatefile("${path.module}/values/gatus.yaml", {
    issuer            = var.cluster_issuer
    domain            = local.gatus_domain
    domain_tls_secret = local.gatus_tls_secret
  })]
}
