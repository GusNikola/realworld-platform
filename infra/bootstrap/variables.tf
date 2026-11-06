variable "region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "Target AWS account ID. The provider refuses to run against any other account."
  type        = string
}

variable "project" {
  description = "Project name, used as the prefix for all resource names."
  type        = string
  default     = "realworld"
}

variable "github_owner" {
  description = "GitHub user or organization that owns the repositories."
  type        = string
}

variable "github_owner_id" {
  description = "Numeric ID of the GitHub owner, part of the immutable OIDC subject."
  type        = string
  default     = "91568541"
}

variable "github_repo_ids" {
  description = "Numeric IDs of the repositories allowed to assume the GitHub Actions roles."
  type        = map(string)
  default = {
    realworld-platform = "1441109328"
    realworld-backend  = "1441109272"
    realworld-frontend = "1441109299"
  }
}

variable "platform_repo" {
  description = "Repository holding Terraform and GitOps code."
  type        = string
  default     = "realworld-platform"
}

variable "app_repos" {
  description = "Application repositories allowed to push images to ECR."
  type        = list(string)
  default     = ["realworld-backend", "realworld-frontend"]
}

variable "ecr_push_branches" {
  description = "Branches of the application repositories allowed to push images."
  type        = list(string)
  default     = ["main", "dev"]
}

variable "terraform_apply_environments" {
  description = "GitHub environments allowed to assume the Terraform apply role."
  type        = list(string)
  default     = ["prod", "dev"]
}

variable "tfstate_admin_principal_arns" {
  description = "Human/admin principals (besides the Terraform CI roles) allowed to access the state bucket. Use role/user ARNs; for assumed roles use the role ARN."
  type        = list(string)
}

variable "domain_name" {
  description = "Subdomain delegated to Route 53; all application hostnames live under it."
  type        = string
}

variable "parent_domain" {
  description = "Parent domain hosted on Cloudflare, where the NS delegation records are created."
  type        = string
}
