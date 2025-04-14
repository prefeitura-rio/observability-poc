resource "helm_release" "gatus" {
  depends_on       = [var.node_pool]
  name             = "gatus"
  repository       = "https://twin.github.io/helm-charts"
  chart            = "gatus"
  version          = "1.2.0"
  namespace        = "gatus"
  create_namespace = true
  values = [templatefile("${path.module}/values/gatus.yaml", {
    issuer            = var.cluster_issuer
    domain            = "gatus.${var.k8s_domain}"
    domain_tls_secret = replace("${var.k8s_domain}-tls", ".", "-")
  })]
}
