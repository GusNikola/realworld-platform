provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "realworld"
      Layer       = "infra"
      Environment = "dev"
      ManagedBy   = "terraform"
      Repository  = "GusNikola/realworld-platform"
    }
  }
}
