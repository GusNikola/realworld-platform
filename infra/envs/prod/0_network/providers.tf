provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "realworld"
      Layer       = "network"
      Environment = "prod"
      ManagedBy   = "terraform"
      Repository  = "GusNikola/realworld-platform"
    }
  }
}
