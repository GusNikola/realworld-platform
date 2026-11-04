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
