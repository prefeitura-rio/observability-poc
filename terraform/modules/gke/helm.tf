resource "helm_release" "gatus" {
  depends_on       = [google_container_node_pool.poc]
  name             = "gatus"
  repository       = "https://twin.github.io/helm-charts"
  chart            = "gatus"
  namespace        = "gatus"
  create_namespace = true
  values           = [file("./k8s/values/gatus.yaml")]
}
