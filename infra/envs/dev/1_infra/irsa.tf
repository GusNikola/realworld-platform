# IAM roles for cluster add-ons installed later by ArgoCD (2_platform).
locals {
  irsa = {
    oidc_provider_arn = module.eks.oidc_provider_arn
    oidc_issuer       = module.eks.oidc_issuer
  }
}

module "irsa_aws_load_balancer_controller" {
  source = "../../../modules/irsa"

  name              = "${local.name}-aws-load-balancer-controller"
  oidc_provider_arn = local.irsa.oidc_provider_arn
  oidc_issuer       = local.irsa.oidc_issuer
  namespace         = "kube-system"
  service_account   = "aws-load-balancer-controller"
  # Upstream policy for aws-load-balancer-controller v3.6.2.
  policy_json = file("${path.root}/../../../policies/aws-load-balancer-controller.json")
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${data.terraform_remote_state.bootstrap.outputs.hosted_zone_id}"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources",
    ]
    resources = ["*"]
  }
}

module "irsa_external_dns" {
  source = "../../../modules/irsa"

  name              = "${local.name}-external-dns"
  oidc_provider_arn = local.irsa.oidc_provider_arn
  oidc_issuer       = local.irsa.oidc_issuer
  namespace         = "external-dns"
  service_account   = "external-dns"
  policy_json       = data.aws_iam_policy_document.external_dns.json
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      aws_secretsmanager_secret.backend.arn,
      module.rds.master_user_secret_arn,
    ]
  }
}

module "irsa_external_secrets" {
  source = "../../../modules/irsa"

  name              = "${local.name}-external-secrets"
  oidc_provider_arn = local.irsa.oidc_provider_arn
  oidc_issuer       = local.irsa.oidc_issuer
  namespace         = "external-secrets"
  service_account   = "external-secrets"
  policy_json       = data.aws_iam_policy_document.external_secrets.json
}

data "aws_iam_policy_document" "loki" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.loki.arn]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.loki.arn}/*"]
  }
}

module "irsa_loki" {
  source = "../../../modules/irsa"

  name              = "${local.name}-loki"
  oidc_provider_arn = local.irsa.oidc_provider_arn
  oidc_issuer       = local.irsa.oidc_issuer
  namespace         = "monitoring"
  service_account   = "loki"
  policy_json       = data.aws_iam_policy_document.loki.json
}
