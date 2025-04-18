locals {
  app_domain     = "app.${var.k8s_domain}"
  app_tls_secret = replace("${local.app_domain}-tls", ".", "-")
  otel_collector = "${helm_release.opentelemetry_collector.metadata[0].name}.${helm_release.opentelemetry_collector.metadata[0].namespace}.svc.cluster.local:4317"
}

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
    replicas = 1

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

          env {
            name  = "OTEL_SERVICE_NAME"
            value = "app-with-ingress"
          }

          env {
            name  = "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"
            value = "true"
          }

          env {
            name  = "OTEL_METRICS_EXPORTER"
            value = "otlp"
          }

          env {
            name  = "OTEL_LOGS_EXPORTER"
            value = "otlp"
          }

          env {
            name  = "OTEL_TRACES_EXPORTER"
            value = "none"
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
            value = local.otel_collector
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_INSECURE"
            value = "true"
          }

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
    replicas = 1

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

          env {
            name  = "OTEL_SERVICE_NAME"
            value = "app-without-ingress"
          }

          env {
            name  = "OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"
            value = "true"
          }

          env {
            name  = "OTEL_METRICS_EXPORTER"
            value = "otlp"
          }

          env {
            name  = "OTEL_LOGS_EXPORTER"
            value = "otlp"
          }

          env {
            name  = "OTEL_TRACES_EXPORTER"
            value = "none"
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
            value = local.otel_collector
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_INSECURE"
            value = "true"
          }

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
      hosts       = [local.app_domain]
      secret_name = local.app_tls_secret
    }

    rule {
      host = local.app_domain
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
