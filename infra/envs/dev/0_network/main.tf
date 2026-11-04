locals {
  name = "realworld-dev"
}

module "network" {
  source = "../../../modules/network"

  name     = local.name
  vpc_cidr = "10.20.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
  app_subnet_cidrs    = ["10.20.16.0/20", "10.20.32.0/20"]
  data_subnet_cidrs   = ["10.20.200.0/24", "10.20.201.0/24"]

  single_nat_gateway = true
}
