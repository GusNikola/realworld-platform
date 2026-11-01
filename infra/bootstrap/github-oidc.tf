# GitHub Actions authenticates to AWS with short-lived OIDC tokens; no static keys exist.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://${local.github_oidc_url}"
  client_id_list = ["sts.amazonaws.com"]
}

# -----------------------------------------------------------------------------
# terraform-plan: read-only, assumable from pull requests in the platform repo.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "terraform_plan_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:sub"
      values = [
        "repo:${var.github_owner}/${var.platform_repo}:pull_request",
        "repo:${var.github_owner}/${var.platform_repo}:ref:refs/heads/main",
      ]
    }
  }
}

resource "aws_iam_role" "terraform_plan" {
  name                 = "${local.prefix}-gha-terraform-plan"
  description          = "GitHub Actions: terraform plan (read-only) for ${var.platform_repo}"
  assume_role_policy   = data.aws_iam_policy_document.terraform_plan_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "terraform_plan_readonly" {
  role       = aws_iam_role.terraform_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Plan acquires the S3 lock, so it needs to write and delete *.tflock objects.
data "aws_iam_policy_document" "terraform_plan_state" {
  statement {
    sid       = "ListStateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }

  statement {
    sid       = "ManageLockFiles"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/*.tflock"]
  }
}

resource "aws_iam_role_policy" "terraform_plan_state" {
  name   = "tfstate-access"
  role   = aws_iam_role.terraform_plan.id
  policy = data.aws_iam_policy_document.terraform_plan_state.json
}

# -----------------------------------------------------------------------------
# terraform-apply: full access, only from protected GitHub environments.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "terraform_apply_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:sub"
      values = [
        for env in var.terraform_apply_environments :
        "repo:${var.github_owner}/${var.platform_repo}:environment:${env}"
      ]
    }
  }
}

resource "aws_iam_role" "terraform_apply" {
  name                 = "${local.prefix}-gha-terraform-apply"
  description          = "GitHub Actions: terraform apply for ${var.platform_repo} (protected environments only)"
  assume_role_policy   = data.aws_iam_policy_document.terraform_apply_trust.json
  max_session_duration = 7200 # EKS create/upgrade can exceed one hour
}

resource "aws_iam_role_policy_attachment" "terraform_apply_admin" {
  role       = aws_iam_role.terraform_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# -----------------------------------------------------------------------------
# ecr-push: single role shared by the application repos
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "ecr_push_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_url}:sub"
      values = flatten([
        for repo in var.app_repos : [
          for branch in var.ecr_push_branches :
          "repo:${var.github_owner}/${repo}:ref:refs/heads/${branch}"
        ]
      ])
    }
  }
}

resource "aws_iam_role" "ecr_push" {
  name                 = "${local.prefix}-gha-ecr-push"
  description          = "GitHub Actions: push application images to ECR"
  assume_role_policy   = data.aws_iam_policy_document.ecr_push_trust.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid       = "GetAuthToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "PushAndPullProjectImages"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${var.account_id}:repository/${var.project}-*",
    ]
  }
}

resource "aws_iam_role_policy" "ecr_push" {
  name   = "ecr-push"
  role   = aws_iam_role.ecr_push.id
  policy = data.aws_iam_policy_document.ecr_push.json
}
