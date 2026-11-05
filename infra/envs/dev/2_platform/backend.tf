terraform {
  backend "s3" {
    bucket       = "realworld-bootstrap-tfstate-973122996566"
    key          = "dev/2_platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
