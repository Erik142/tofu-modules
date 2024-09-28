variable "flux_cluster_name" {
  type = string
}

variable "flux_interval" {
  type    = string
  default = "1m0s"
}

variable "flux_github_owner" {
  type = string
}

variable "flux_github_repository" {
  type = string
}

variable "flux_github_repository_branch" {
  type = string
}

variable "flux_github_secrets_repository" {
  type = string
}

variable "flux_github_token" {
  sensitive = true
  type      = string
}

variable "flux_age_private_key" {
  sensitive = true
  type      = string
}

variable "flux_kubernetes_cluster_endpoint" {
  type = string
}

variable "flux_kubernetes_cluster_ca_certificate" {
  type = string
}

variable "flux_kubernetes_client_certificate" {
  type = string
}

variable "flux_kubernetes_client_key" {
  sensitive = true
  type      = string
}
