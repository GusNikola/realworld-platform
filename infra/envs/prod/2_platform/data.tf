data "aws_caller_identity" "current" {}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket = "realworld-bootstrap-tfstate-973122996566"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "realworld-bootstrap-tfstate-973122996566"
    key    = "prod/1_infra/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  env       = "prod"
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  infra     = data.terraform_remote_state.infra.outputs

  domain       = local.bootstrap.domain_name
  app_host     = local.domain
  argocd_host  = "argocd.${local.domain}"
  grafana_host = "grafana.${local.domain}"

  gitops_repo_url = "https://github.com/GusNikola/realworld-platform.git"
}
