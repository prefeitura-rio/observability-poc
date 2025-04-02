resource "google_compute_address" "poc_ingress" {
  name         = "poc-ingress"
  address_type = "EXTERNAL"
}

resource "helm_release" "ingress-nginx" {
  depends_on       = [google_container_node_pool.poc]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.1"
  namespace        = "ingress-nginx"
  create_namespace = true
  values           = [templatefile("${path.module}/values/nginx.yaml", { load_balancer_ip = google_compute_address.poc_ingress.address })]
}

resource "helm_release" "cert-manager" {
  depends_on       = [google_container_node_pool.poc]
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

locals {
  cert_manager_cluster_issuer = "letsencrypt"
}

resource "kubectl_manifest" "cluster-issuer" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cert_manager_cluster_issuer}
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: ${local.cert_manager_cluster_issuer}-key
    solvers:
    - http01:
        ingress:
          ingressClassName: "nginx"
YAML

}

resource "helm_release" "gatus" {
  depends_on       = [google_container_node_pool.poc]
  name             = "gatus"
  repository       = "https://twin.github.io/helm-charts"
  chart            = "gatus"
  version          = "1.2.0"
  namespace        = "gatus"
  create_namespace = true
  values           = [file("${path.module}/values/gatus.yaml")]
}

resource "kubernetes_namespace_v1" "prometheus" {
  depends_on = [google_container_node_pool.poc]
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "70.4.1"
  namespace  = kubernetes_namespace_v1.prometheus.metadata[0].name
  values     = [file("${path.module}/values/prometheus.yaml")]
}
