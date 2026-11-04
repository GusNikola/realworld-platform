data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket = "realworld-bootstrap-tfstate-973122996566"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "realworld-bootstrap-tfstate-973122996566"
    key    = "dev/0_network/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  network = data.terraform_remote_state.network.outputs
}
