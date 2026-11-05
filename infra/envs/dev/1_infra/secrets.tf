# Application secrets for the backend. Values are generated as ephemeral values and
# written through a write-only argument, so they are never stored in Terraform state.
ephemeral "random_password" "jwt_secret_key" {
  length  = 64
  special = false
}

ephemeral "random_password" "secret_key" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "backend" {
  name                    = "${local.name}/backend"
  description             = "Backend application secrets, synced into Kubernetes by External Secrets"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "backend" {
  secret_id = aws_secretsmanager_secret.backend.id

  secret_string_wo = jsonencode({
    JWT_SECRET_KEY = ephemeral.random_password.jwt_secret_key.result
    SECRET_KEY     = ephemeral.random_password.secret_key.result
  })
  # Bump to regenerate and rotate both values.
  secret_string_wo_version = 1
}

# Admin passwords for the ArgoCD and Grafana UIs, generated the same way. ArgoCD needs a
# bcrypt hash, kept in its own secret so 2_platform can read it without the plain
# password reaching Terraform state; Grafana gets its password through External Secrets.
ephemeral "random_password" "argocd_admin" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "argocd_admin" {
  name                    = "${local.name}/argocd-admin"
  description             = "ArgoCD admin password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd_admin" {
  secret_id = aws_secretsmanager_secret.argocd_admin.id

  secret_string_wo = jsonencode({
    password = ephemeral.random_password.argocd_admin.result
  })
  # Bump together with argocd_admin_bcrypt to generate a new password, then apply
  # 2_platform to push the new hash.
  secret_string_wo_version = 2
}

resource "aws_secretsmanager_secret" "argocd_admin_bcrypt" {
  name                    = "${local.name}/argocd-admin-bcrypt"
  description             = "bcrypt hash of the ArgoCD admin password, read by 2_platform"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd_admin_bcrypt" {
  secret_id                = aws_secretsmanager_secret.argocd_admin_bcrypt.id
  secret_string_wo         = bcrypt(ephemeral.random_password.argocd_admin.result)
  secret_string_wo_version = 2
}

ephemeral "random_password" "grafana_admin" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "grafana_admin" {
  name                    = "${local.name}/grafana-admin"
  description             = "Grafana admin credentials, synced into Kubernetes by External Secrets"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id = aws_secretsmanager_secret.grafana_admin.id

  secret_string_wo = jsonencode({
    admin-user     = "admin"
    admin-password = ephemeral.random_password.grafana_admin.result
  })
  secret_string_wo_version = 1
}
