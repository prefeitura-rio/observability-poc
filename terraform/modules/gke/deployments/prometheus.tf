resource "helm_release" "prometheus" {
  depends_on       = [var.node_pool]
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "70.4.1"
  namespace        = "prometheus"
  create_namespace = true
  values           = [file("${path.module}/values/prometheus.yaml")]
}


resource "google_dns_record_set" "poc_k8s_prometheus_cname" {
  name         = "${local.prometheus_domain}."
  managed_zone = "dados-rio"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = local.rrdatas
}

resource "kubernetes_ingress_v1" "prometheus" {
  depends_on = [
    helm_release.prometheus,
    google_dns_record_set.poc_k8s_prometheus_cname,
  ]

  metadata {
    name      = "prometheus"
    namespace = "prometheus"
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cluster_issuer
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.prometheus_domain]
      secret_name = replace(local.prometheus_domain, ".", "-")
    }

    rule {
      host = local.prometheus_domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = "prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }
}
