locals {
  github_known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  flux_namespace     = "flux-system"
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = local.flux_namespace
  }
}

resource "kubernetes_secret" "sops_age" {
  depends_on = [kubernetes_namespace.flux_system]
  metadata {
    name      = "sops-age"
    namespace = local.flux_namespace
  }

  binary_data = {
    "age.agekey" = var.flux_age_private_key
  }
}

resource "kubernetes_secret" "github_secrets" {
  depends_on = [kubernetes_namespace.flux_system]

  metadata {
    name      = "github-secrets"
    namespace = local.flux_namespace
  }

  data = {
    identity       = tls_private_key.github_secrets.private_key_pem
    "identity.pub" = tls_private_key.github_secrets.public_key_pem
    known_hosts    = local.github_known_hosts
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on       = [github_repository_deploy_key.this, kubernetes_secret.sops_age, kubernetes_secret.github_secrets]
  path             = "clusters/${var.flux_cluster_name}"
  components_extra = ["image-reflector-controller", "image-automation-controller"]
  interval         = var.flux_interval
}
