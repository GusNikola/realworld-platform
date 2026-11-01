# First run on a fresh account must use local state;
terraform {
  backend "s3" {
    bucket       = "realworld-bootstrap-tfstate-973122996566"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
