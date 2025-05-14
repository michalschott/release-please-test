resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.0.3"

  name      = "argocd"
  namespace = "argocd"

  create_namespace = true
  wait_for_jobs    = true
}

data "kubernetes_secret" "argocd_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = helm_release.argocd.namespace
  }
}

locals {
  vpcCIDR = "10.0.0.0/16"
}

resource "argocd_application_set" "control" {
  metadata {
    name      = "control"
    namespace = helm_release.argocd.namespace
  }

  spec {
    go_template = true
    go_template_options = [
      "missingkey=error",
    ]
    generator {
      git {
        repo_url = "https://github.com/michalschott/release-please-test.git"
        revision = "HEAD"
        file {
          path = format("helm/*/values.%s.yaml", var.environment)
        }
      }
    }
    template {
      metadata {
        name = "{{.path.basename}}"
      }
      spec {
        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "{{.path.basename}}"
        }
        source {
          path            = "helm/{{.path.basename}}"
          repo_url        = "https://github.com/michalschott/release-please-test.git"
          target_revision = "HEAD"
          helm {
            ignore_missing_value_files = true
            value_files = [
              "values.yaml",
              format("values.%s.yaml", var.environment),
            ]
            parameter {
              name = "environment"
              value = var.environment
            }
            parameter {
              name = "vpcCIDR"
              value = local.vpcCIDR
            }
          }
        }
        sync_policy {
          automated {
            prune     = true
            self_heal = true
          }
          sync_options = ["CreateNamespace=true"]
        }
      }
    }
  }
}
