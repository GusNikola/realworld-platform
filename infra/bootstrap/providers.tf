provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Layer       = "bootstrap"
      Environment = "global"
      ManagedBy   = "terraform"
      Repository  = "${var.github_owner}/${var.platform_repo}"
    }
  }
}
