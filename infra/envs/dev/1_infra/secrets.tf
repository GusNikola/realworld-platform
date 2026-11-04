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

# Admin passwords for the ArgoCD and Grafana UIs, generated the same way. ArgoCD reads
# its password in 2_platform (stored bcrypt-hashed); Grafana gets it through External Secrets.
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
  secret_string_wo_version = 1
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
