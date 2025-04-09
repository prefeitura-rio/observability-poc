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

resource "kubernetes_secret" "loki_secrets_gsa" {
  depends_on = [helm_release.prometheus]
  metadata {
    name      = "loki-secrets-gsa"
    namespace = "prometheus"
  }
  data = {
    "gcp_service_account.json" = base64decode(google_service_account_key.loki.private_key)
  }
}

resource "google_dns_record_set" "poc_k8s_loki_cname" {
  name         = "${local.loki_domain}."
  managed_zone = "dados-rio"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = local.rrdatas
}

resource "helm_release" "loki" {
  depends_on = [kubernetes_secret.loki_secrets_gsa, google_dns_record_set.poc_k8s_loki_cname]
  version    = "6.29.0"
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = "prometheus"
  wait       = true
  timeout    = 600
  values = [templatefile("${path.module}/values/loki.yaml", {
    bucket_name       = var.loki_bucket_name
    domain            = local.loki_domain
    domain_tls_secret = replace(local.loki_domain, ".", "-")
    issuer            = var.cluster_issuer
    password          = var.loki_password
    user              = var.loki_user
  })]
}
