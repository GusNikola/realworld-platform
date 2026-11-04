variable "name" {
  description = "Name prefix, e.g. realworld-prod."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  description = "Private subnet for the host. It needs outbound access (NAT) for SSM and GitHub."
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "disk_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 30
}

variable "runner_version" {
  description = "GitHub Actions runner version installed on the host."
  type        = string
}

variable "runner_sha256" {
  description = "SHA-256 of the actions-runner-linux-x64 tarball for runner_version."
  type        = string
}
