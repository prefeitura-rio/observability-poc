locals {
  cert_manager_cluster_issuer = "letsencrypt"
}

# Ingress ------------------------------------------
resource "google_compute_address" "poc_ingress" {
  name         = "poc-ingress"
  address_type = "EXTERNAL"
}

resource "helm_release" "ingress-nginx" {
  depends_on       = [google_container_node_pool.poc]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.1"
  namespace        = "ingress-nginx"
  create_namespace = true
  values           = [templatefile("${path.module}/values/nginx.yaml", { load_balancer_ip = google_compute_address.poc_ingress.address })]
}

resource "helm_release" "cert-manager" {
  depends_on       = [google_container_node_pool.poc]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.17.1"
  namespace        = "cert-manager"
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "cluster-issuer" {
  depends_on = [helm_release.cert-manager, helm_release.ingress-nginx]
  yaml_body  = templatefile("${path.module}/manifests/cert-manager.yaml", { issuer = local.cert_manager_cluster_issuer })
}

# Gatus --------------------------------------------
resource "helm_release" "gatus" {
  depends_on       = [google_container_node_pool.poc]
  name             = "gatus"
  repository       = "https://twin.github.io/helm-charts"
  chart            = "gatus"
  version          = "1.2.0"
  namespace        = "gatus"
  create_namespace = true
  values           = [file("${path.module}/values/gatus.yaml")]
}

# Prometheus ---------------------------------------
resource "helm_release" "prometheus" {
  depends_on       = [google_container_node_pool.poc]
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "70.4.1"
  namespace        = "prometheus"
  create_namespace = true
  values           = [file("${path.module}/values/prometheus.yaml")]
}

# Loki --------------------------------------------
resource "google_service_account" "loki" {
  account_id   = "loki-poc"
  display_name = "Loki POC"
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
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = "prometheus"
  wait       = true
  timeout    = 600
  values = [templatefile("${path.module}/values/loki.yaml", {
    cert_manager_cluster_issuer = local.cert_manager_cluster_issuer
    password                    = var.loki_password
    user                        = var.loki_user
    domain                      = var.loki_domain
    domain_tls_secret           = replace(var.loki_domain, ".", "-")
    bucket_name                 = var.loki_bucket_name
  })]
}

# Promtail -----------------------------------------
resource "helm_release" "promtail" {
  depends_on       = [kubernetes_secret.loki-secrects-gsa]
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = "prometheus"
  create_namespace = true
  values = [templatefile("${path.module}/values/promtail.yaml", {
    password = var.loki_password
    user     = var.loki_user
  })]
}
