resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux (OpenTofu)"
  repository = var.flux_github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "tls_private_key" "github_secrets" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "secrets_deploy_key" {
  title      = "Flux (OpenTofu)"
  repository = var.flux_github_secrets_repository
  key        = tls_private_key.github_secrets.public_key_openssh
  read_only  = "false"
}
