terraform {
  required_version = "~> 1.11"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

provider "argocd" {
  username                    = "admin"
  password                    = data.kubernetes_secret.argocd_password.data.password
  port_forward_with_namespace = "argocd"
  kubernetes {
    config_context = "minikube"
  }
}
