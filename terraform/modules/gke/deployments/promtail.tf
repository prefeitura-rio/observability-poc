resource "helm_release" "promtail" {
  depends_on       = [kubernetes_secret.loki-secrects-gsa]
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = "prometheus"
  create_namespace = true
  values = [templatefile("${path.module}/values/promtail.yaml", {
    password = var.loki_password
    user     = var.loki_user
  })]
}
