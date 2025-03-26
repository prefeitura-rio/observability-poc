resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app = "app"
        }
      }

      spec {
        container {
          image = "ghcr.io/prefeitura-rio/observability-poc:latest"
          name  = "app"

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

resource "kubernetes_service" "app" {
  metadata {
    name      = "app"
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
