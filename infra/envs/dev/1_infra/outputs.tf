output "vpc_id" {
  value = local.network.vpc_id
}

output "vpc_cidr" {
  value = local.network.vpc_cidr
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_issuer" {
  value = module.eks.oidc_issuer
}

output "karpenter_controller_role_arn" {
  value = module.eks.karpenter_controller_role_arn
}

output "karpenter_node_role_name" {
  value = module.eks.karpenter_node_role_name
}

output "karpenter_interruption_queue_name" {
  value = module.eks.karpenter_interruption_queue_name
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ops_host_instance_id" {
  value = module.ops_host.instance_id
}

output "rds_address" {
  value = module.rds.address
}

output "rds_port" {
  value = module.rds.port
}

output "rds_db_name" {
  value = module.rds.db_name
}

output "rds_master_user_secret_arn" {
  value = module.rds.master_user_secret_arn
}

output "backend_secret_name" {
  value = aws_secretsmanager_secret.backend.name
}

output "argocd_admin_secret_name" {
  value = aws_secretsmanager_secret.argocd_admin.name
}

output "argocd_admin_bcrypt_secret_name" {
  value = aws_secretsmanager_secret.argocd_admin_bcrypt.name
}

output "grafana_admin_secret_name" {
  value = aws_secretsmanager_secret.grafana_admin.name
}

output "argocd_webhook_secret_name" {
  value = aws_secretsmanager_secret.argocd_webhook.name
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}

output "waf_web_acl_name" {
  value = module.waf.web_acl_name
}

output "loki_bucket" {
  value = aws_s3_bucket.loki.bucket
}

output "irsa_role_arns" {
  value = {
    aws_load_balancer_controller = module.irsa_aws_load_balancer_controller.role_arn
    external_dns                 = module.irsa_external_dns.role_arn
    external_secrets             = module.irsa_external_secrets.role_arn
    loki                         = module.irsa_loki.role_arn
  }
}
