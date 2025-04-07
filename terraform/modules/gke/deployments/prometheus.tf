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

resource "kubernetes_ingress_v1" "prometheus" {
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
      hosts       = [var.prometheus_k8s_domain]
      secret_name = replace(var.prometheus_k8s_domain, ".", "-")
    }

    rule {
      host = var.prometheus_k8s_domain
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
