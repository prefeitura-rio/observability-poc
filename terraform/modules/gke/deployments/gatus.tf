resource "helm_release" "gatus" {
  depends_on       = [var.node_pool]
  name             = "gatus"
  repository       = "https://twin.github.io/helm-charts"
  chart            = "gatus"
  version          = "1.2.0"
  namespace        = "gatus"
  create_namespace = true
  values           = [file("${path.module}/values/gatus.yaml")]
}

resource "kubernetes_ingress_v1" "gatus" {
  metadata {
    name      = "gatus"
    namespace = "gatus"
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cluster_issuer
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.gatus_k8s_domain]
      secret_name = replace(var.gatus_k8s_domain, ".", "-")
    }

    rule {
      host = var.gatus_k8s_domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = "gatus"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}
