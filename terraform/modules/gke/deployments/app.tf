resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "app"
  }
}

resource "kubernetes_deployment_v1" "app_with_ingress" {
  depends_on = [kubernetes_namespace_v1.app]

  metadata {
    name      = "app-with-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels = {
      app = "app-with-ingress"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app-with-ingress"
      }
    }

    template {
      metadata {
        labels = {
          app = "app-with-ingress"
        }
      }

      spec {
        container {
          image = "ghcr.io/prefeitura-rio/observability-poc/app:latest"
          name  = "app-with-ingress"

          port {
            container_port = 8000
            name           = "http"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "app_without_ingress" {
  depends_on = [kubernetes_namespace_v1.app]

  metadata {
    name      = "app-without-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels = {
      app = "app-without-ingress"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app-without-ingress"
      }
    }

    template {
      metadata {
        labels = {
          app = "app-without-ingress"
        }
      }

      spec {
        container {
          image = "ghcr.io/prefeitura-rio/observability-poc/app:latest"
          name  = "app-without-ingress"

          port {
            container_port = 8000
            name           = "http"

          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app_with_ingress" {
  depends_on = [kubernetes_deployment_v1.app_with_ingress]

  metadata {
    name      = "app-with-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.app_with_ingress.metadata[0].labels.app
    }
    port {
      port        = 8000
      target_port = 8000
      name        = "http"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service_v1" "app_without_ingress" {
  depends_on = [kubernetes_deployment_v1.app_without_ingress]
  metadata {
    name      = "app-without-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.app_without_ingress.metadata[0].labels.app
    }
    port {
      port        = 8000
      target_port = 8000
      name        = "http"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app_with_ingress" {
  depends_on = [kubernetes_service_v1.app_with_ingress, helm_release.ingress_nginx]
  metadata {
    name      = "app-with-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cluster_issuer
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = ["app.${var.k8s_domain}"]
      secret_name = replace("${var.k8s_domain}-tls", ".", "-")
    }

    rule {
      host = "app.${var.k8s_domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.app_with_ingress.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}
