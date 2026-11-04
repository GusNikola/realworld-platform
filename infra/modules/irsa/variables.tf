variable "name" {
  description = "IAM role name."
  type        = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer" {
  description = "OIDC issuer host and path, without https://."
  type        = string
}

variable "namespace" {
  type = string
}

variable "service_account" {
  type = string
}

variable "policy_json" {
  description = "Inline policy attached to the role."
  type        = string
}
