resource "kubernetes_namespace_v1" "app_without_ingress" {
  metadata {
    name = "app-without-ingress"
  }
}

resource "kubernetes_deployment_v1" "app_without_ingress" {
  depends_on = [kubernetes_namespace_v1.app_without_ingress]

  metadata {
    name      = "app-without-ingress"
    namespace = kubernetes_namespace_v1.app_without_ingress.metadata[0].name
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

resource "kubernetes_service_v1" "app_without_ingress" {
  depends_on = [kubernetes_deployment_v1.app_without_ingress]
  metadata {
    name      = "app-without-ingress"
    namespace = kubernetes_namespace_v1.app_without_ingress.metadata[0].name
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
