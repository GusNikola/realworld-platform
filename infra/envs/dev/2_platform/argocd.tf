# ArgoCD is the only workload Terraform installs in the cluster; everything else is
# synced by ArgoCD from gitops/.
# Only the bcrypt hash is read (and stored in state); the plain password stays in
# the argocd-admin secret. A data source is used instead of a write-only argument because
# write-only values are not resent on later helm upgrades, which would reset the password.
data "aws_secretsmanager_secret_version" "argocd_admin" {
  secret_id = local.infra.argocd_admin_bcrypt_secret_name
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.11.7"

  values = [file("${path.module}/values/argocd.yaml")]

  set_sensitive = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = data.aws_secretsmanager_secret_version.argocd_admin.secret_string
    },
  ]
}
