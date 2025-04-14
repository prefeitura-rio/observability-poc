resource "helm_release" "promtail" {
  depends_on = [
    kubernetes_secret.loki_secrets_gsa,
    helm_release.cert_manager,
    helm_release.ingress_nginx,
  ]

  version          = "6.16.6"
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = "prometheus"
  create_namespace = true
  values = [templatefile("${path.module}/values/promtail.yaml", {
    password     = var.loki_password
    user         = var.loki_user
    loki_gateway = "${helm_release.loki.metadata[0].name}-gateway.${helm_release.loki.metadata[0].namespace}.svc.cluster.local"
  })]
}
