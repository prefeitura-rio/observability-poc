resource "google_service_account" "loki" {
  account_id   = "loki-poc"
  display_name = "loki-poc"
  project      = var.project_id
}

resource "google_service_account_key" "loki" {
  service_account_id = google_service_account.loki.name
}

resource "google_storage_bucket_iam_binding" "loki" {
  bucket  = var.loki_bucket_name
  role    = "roles/storage.objectUser"
  members = ["serviceAccount:${google_service_account.loki.email}"]
}

resource "kubernetes_secret" "loki-secrects-gsa" {
  depends_on = [helm_release.prometheus]
  metadata {
    name      = "loki-secrets-gsa"
    namespace = "prometheus"
  }
  data = {
    "gcp_service_account.json" = base64decode(google_service_account_key.loki.private_key)
  }
}

resource "helm_release" "loki" {
  depends_on = [kubernetes_secret.loki-secrects-gsa]
  version    = "6.29.0"
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = "prometheus"
  wait       = true
  timeout    = 600
  values = [templatefile("${path.module}/values/loki.yaml", {
    cert_manager_cluster_issuer = var.cluster_issuer
    password                    = var.loki_password
    user                        = var.loki_user
    domain                      = var.loki_k8s_domain
    domain_tls_secret           = replace(var.loki_k8s_domain, ".", "-")
    bucket_name                 = var.loki_bucket_name
  })]
}

resource "kubernetes_ingress_v1" "loki" {
  metadata {
    name      = "loki"
    namespace = "prometheus"
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cluster_issuer
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.loki_k8s_domain]
      secret_name = replace(var.loki_k8s_domain, ".", "-")
    }

    rule {
      host = var.loki_k8s_domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = "loki"
              port {
                number = 3100
              }
            }
          }
        }
      }
    }
  }
}
