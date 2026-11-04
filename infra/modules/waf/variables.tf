variable "name" {
  description = "Web ACL name, also used as the CloudWatch metric prefix."
  type        = string
}

variable "rate_limit_global" {
  description = "Maximum requests per client IP in a 5 minute window, across the whole site."
  type        = number
  default     = 1000
}

variable "rate_limit_auth" {
  description = "Maximum POST requests per client IP in a 5 minute window to /api/users (login and registration)."
  type        = number
  default     = 20
}
