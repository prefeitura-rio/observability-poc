resource "helm_release" "opentelemetry_collector" {
  depends_on = [var.node_pool]

  name             = "opentelemetry-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  version          = "0.122.0"
  namespace        = "otel"
  create_namespace = true
  values = [templatefile("${path.module}/values/otel.yaml", {
    mode       = "deployment"
    prometheus = local.prometheus
    loki       = "${helm_release.loki.metadata[0].name}-gateway.${helm_release.loki.metadata[0].namespace}.svc.cluster.local"
  })]
}
