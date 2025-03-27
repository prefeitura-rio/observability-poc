resource "kubernetes_namespace" "app_with_ingress" {
  metadata {
    name = "app-with-ingress"
  }
}

resource "kubernetes_deployment" "app_with_ingress" {
  depends_on = [kubernetes_namespace.app_with_ingress]
  metadata {
    name      = "app-with-ingress"
    namespace = kubernetes_namespace.app_with_ingress.metadata[0].name
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
          image = "ghcr.io/prefeitura-rio/observability-poc:latest"
          name  = "app-with-ingress"

          port {
            container_port = 8000
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

resource "kubernetes_service" "app_with_ingress" {
  depends_on = [kubernetes_deployment.app_with_ingress]
  metadata {
    name      = "app-with-ingress"
    namespace = kubernetes_namespace.app_with_ingress.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app_with_ingress.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8000
    }
    type = "ClusterIP"
  }
}
