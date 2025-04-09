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

resource "google_dns_record_set" "poc_k8s_gatus_cname" {
  name         = "${local.gatus_domain}."
  managed_zone = "dados-rio"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = local.rrdatas
}

resource "kubernetes_ingress_v1" "gatus" {
  depends_on = [
    helm_release.gatus,
    helm_release.ingress_nginx,
    google_dns_record_set.poc_k8s_gatus_cname
  ]

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
      hosts       = [local.gatus_domain]
      secret_name = replace(local.gatus_domain, ".", "-")
    }

    rule {
      host = local.gatus_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
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
