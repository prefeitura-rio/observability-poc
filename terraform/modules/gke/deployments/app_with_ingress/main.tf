resource "kubernetes_namespace" "app_with_ingress" {
  metadata {
    name = "app_with_ingress"
  }
}

resource "kubernetes_deployment" "app_with_ingress" {
  metadata {
    name      = "app_with_ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "app_with_ingress"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app_with_ingress"
      }
    }

    template {
      metadata {
        labels = {
          app = "app_with_ingress"
        }
      }

      spec {
        container {
          image = "ghcr.io/prefeitura-rio/observability-poc:latest"
          name  = "app_with_ingress"

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
  metadata {
    name      = "app_with_ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8000
    }
    type = "ClusterIP"
  }
}
