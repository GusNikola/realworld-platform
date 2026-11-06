locals {
  name = "realworld-prod"
}

data "aws_caller_identity" "current" {}

# Workloads may only read this environment's secrets and the RDS-managed master secret
# through the endpoint; the Terraform CI roles may also manage secrets.
data "aws_iam_policy_document" "secretsmanager_endpoint" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:${local.name}/*",
      "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:rds!db-*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  # Terraform runs on the self-hosted runner inside the VPC, so its Secrets Manager
  # calls go through this endpoint too. The CI roles may manage secrets here; their
  # IAM policies still apply (the plan role stays read-only).
  statement {
    actions   = ["secretsmanager:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/realworld-bootstrap-gha-terraform-plan",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/realworld-bootstrap-gha-terraform-apply",
      ]
    }
  }
}

module "network" {
  source = "../../../modules/network"

  name     = local.name
  vpc_cidr = "10.10.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs = ["10.10.0.0/24", "10.10.1.0/24"]
  app_subnet_cidrs    = ["10.10.16.0/20", "10.10.32.0/20"]
  data_subnet_cidrs   = ["10.10.200.0/24", "10.10.201.0/24"]

  app_subnet_tags = {
    "karpenter.sh/discovery" = local.name
  }

  single_nat_gateway = false

  interface_endpoints = ["secretsmanager"]
  interface_endpoint_policies = {
    secretsmanager = data.aws_iam_policy_document.secretsmanager_endpoint.json
  }

  enable_flow_logs         = true
  flow_logs_retention_days = 30
}
