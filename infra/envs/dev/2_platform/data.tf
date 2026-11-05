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
    key    = "dev/1_infra/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  env       = "dev"
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  infra     = data.terraform_remote_state.infra.outputs

  domain       = local.bootstrap.domain_name
  app_host     = "dev.${local.domain}"
  argocd_host  = "argocd-dev.${local.domain}"
  grafana_host = "grafana-dev.${local.domain}"

  gitops_repo_url = "https://github.com/GusNikola/realworld-platform.git"
}
