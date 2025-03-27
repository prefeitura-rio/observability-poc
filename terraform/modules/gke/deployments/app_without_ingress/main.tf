resource "kubernetes_namespace" "app_without_ingress" {
  metadata {
    name = "app-without-ingress"
  }
}

resource "kubernetes_deployment" "app_without_ingress" {
  metadata {
    name      = "app-without-ingress"
    namespace = kubernetes_namespace.app_without_ingress.metadata[0].name
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
          image = "ghcr.io/prefeitura-rio/observability-poc:latest"
          name  = "app-without-ingress"

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

resource "kubernetes_service" "app_without_ingress" {
  metadata {
    name      = "app-without-ingress"
    namespace = kubernetes_namespace.app_without_ingress.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app_without_ingress.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8000
    }
    type = "ClusterIP"
  }
}
