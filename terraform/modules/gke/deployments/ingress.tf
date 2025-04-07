resource "google_compute_address" "poc_ingress" {
  name         = "poc-ingress"
  address_type = "EXTERNAL"
}

resource "helm_release" "ingress-nginx" {
  depends_on       = [var.node_pool]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.1"
  namespace        = "ingress-nginx"
  create_namespace = true
  values = [templatefile("${path.module}/values/nginx.yaml", {
    load_balancer_ip = google_compute_address.poc_ingress.address
  })]
}
