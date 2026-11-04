# ArgoCD is the only workload Terraform installs in the cluster; everything else is
# synced by ArgoCD from gitops/.
ephemeral "aws_secretsmanager_secret_version" "argocd_admin" {
  secret_id = local.infra.argocd_admin_secret_name
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.11.7"

  values = [file("${path.module}/values/argocd.yaml")]

  # ArgoCD expects a bcrypt hash; the plain password stays in Secrets Manager.
  set_wo = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = bcrypt(jsondecode(ephemeral.aws_secretsmanager_secret_version.argocd_admin.secret_string).password)
    },
  ]
  set_wo_revision = var.argocd_admin_password_version
}
