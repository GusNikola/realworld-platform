terraform {
  backend "s3" {
    bucket       = "realworld-bootstrap-tfstate-973122996566"
    key          = "prod/1_infra/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
