# tf-context-to-argocd

This is an example how you can pass context from external source(s) (like vales for helm charts) to ArgoCD with Terraform.

## Install minimal version of operational ArgoCD

First step is to install ArgoCD. The method doesn't really matter - at the end ArgoCD which you are about to install will get updated to the version defined in `helm/argocd` folder.

My example uses `terraform` and `helm provider`:

```bash
  cd terraform/1-install-bare-argocd
  terraform init
  terraform apply --auto-approve
```

## Bootstrap ArgoCD

Next step is the part, where the power of ArgoCD is used to take over cluster lifecycle. An `applicationset` is used to install core applications.

Using `git generator` it looks for existance of `values.${ENV}.yaml` files in `helm` subfolder (even if these are empty). With this metod you can dynamically install / uninstall different applications in different clusters / environments.

```bash
  cd terraform/2-boostrap-argocd
  terraform init
  TF_VAR_environment="dev" terraform apply --auto-approve
```

You should have ArgoCD, external-secrets and cert-manager installed in your cluster.

```bash
  kubectl -n cert-manager get cm info -o yaml
```

You should get a cm with `environment` and `vpcCIDR` populated.

```bash
  TF_VAR_environment="test" terraform apply --auto-approve
```

cert-manager is gone!

Of course this method doesn't prevent race conditions between applications. There is an alpha feature - [Progressive Sync](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Progressive-Syncs/) which could be used to solve that issue and set dependencies of apps. Other approach would be to use `App of apps` pattern and pass context there.
