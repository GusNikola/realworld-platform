output "tfstate_bucket" {
  description = "Remote state bucket for all stacks."
  value       = aws_s3_bucket.tfstate.bucket
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "terraform_plan_role_arn" {
  description = "Role assumed by GitHub Actions for terraform plan."
  value       = aws_iam_role.terraform_plan.arn
}

output "terraform_apply_role_arn" {
  description = "Role assumed by GitHub Actions for terraform apply."
  value       = aws_iam_role.terraform_apply.arn
}

output "ecr_push_role_arn" {
  description = "Role assumed by application repositories to push images."
  value       = aws_iam_role.ecr_push.arn
}

output "domain_name" {
  description = "Delegated subdomain hosting all application hostnames."
  value       = aws_route53_zone.main.name
}

output "hosted_zone_id" {
  description = "Public hosted zone of the delegated subdomain."
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Name servers to add as NS records in Cloudflare for the delegation."
  value       = aws_route53_zone.main.name_servers
}

output "wildcard_certificate_arn" {
  description = "Validated ACM certificate for the apex and *.domain."
  value       = aws_acm_certificate_validation.wildcard.certificate_arn
}
