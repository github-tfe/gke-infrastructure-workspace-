terraform {
  required_version = ">= 0.13"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~>1.7"
    }
    google = {
      source = "hashicorp/google"
      version = "~>4.39"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~>4.40"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = "4.0.0"
    }
  }
}
