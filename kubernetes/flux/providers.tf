provider "flux" {
  kubernetes = {
    host                   = var.flux_kubernetes_cluster_endpoint
    client_certificate     = base64decode(var.flux_kubernetes_client_certificate)
    client_key             = base64decode(var.flux_kubernetes_client_key)
    cluster_ca_certificate = base64decode(var.flux_kubernetes_cluster_ca_certificate)
  }
  git = {
    url    = "ssh://git@github.com/${var.flux_github_owner}/${var.flux_github_repository}.git"
    branch = var.flux_github_repository_branch
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "kubernetes" {
  host = var.flux_kubernetes_cluster_endpoint

  client_certificate     = base64decode(var.flux_kubernetes_client_certificate)
  client_key             = base64decode(var.flux_kubernetes_client_key)
  cluster_ca_certificate = base64decode(var.flux_kubernetes_cluster_ca_certificate)
}

provider "github" {
  owner = var.flux_github_owner
  token = var.flux_github_token
}
