resource "helm_release" "cert_manager" {
  depends_on       = [var.node_pool]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.17.1"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager, helm_release.ingress_nginx]
  yaml_body = templatefile("${path.module}/manifests/cert-manager.yaml", {
    issuer = var.cluster_issuer,
    server = "https://acme-staging-v02.api.letsencrypt.org/directory"
  })
}
