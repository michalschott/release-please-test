resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.0.3"

  name      = "argocd"
  namespace = "argocd"

  create_namespace = true
  wait_for_jobs    = true
}
