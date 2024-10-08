terraform {
  required_version = ">=1.1.5"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">=1.2.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.25.2"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}
