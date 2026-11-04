variable "name" {
  description = "Repository name prefix, e.g. realworld-prod."
  type        = string
}

variable "components" {
  description = "One repository per component, named <name>-<component>."
  type        = list(string)
}

variable "keep_images" {
  description = "Number of most recent images kept per repository."
  type        = number
  default     = 30
}

variable "force_delete" {
  description = "Allow deleting repositories that still contain images."
  type        = bool
  default     = false
}
