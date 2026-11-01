locals {
  name = "realworld-prod"
}

data "aws_caller_identity" "current" {}

# Only allow reading this environment's secrets through the endpoint.
data "aws_iam_policy_document" "secretsmanager_endpoint" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = ["arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:${local.name}/*"]

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
}

module "network" {
  source = "../../../modules/network"

  name     = local.name
  vpc_cidr = "10.10.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs = ["10.10.0.0/24", "10.10.1.0/24"]
  app_subnet_cidrs    = ["10.10.16.0/20", "10.10.32.0/20"]
  data_subnet_cidrs   = ["10.10.200.0/24", "10.10.201.0/24"]

  single_nat_gateway = false

  interface_endpoints = ["secretsmanager"]
  interface_endpoint_policies = {
    secretsmanager = data.aws_iam_policy_document.secretsmanager_endpoint.json
  }

  enable_flow_logs         = true
  flow_logs_retention_days = 30
}
