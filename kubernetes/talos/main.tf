terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
