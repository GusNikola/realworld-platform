variable "name" {
  description = "Identifier prefix, e.g. realworld-prod."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Data subnets (no internet route) for the DB subnet group."
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "Security groups allowed to connect on the Postgres port, keyed by a static name (keys must be known at plan time)."
  type        = map(string)
}

variable "engine_version" {
  description = "Postgres major version; minor versions are upgraded automatically."
  type        = string
  default     = "18"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "allocated_storage" {
  description = "Initial storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GiB."
  type        = number
  default     = 50
}

variable "db_name" {
  type    = string
  default = "realworld"
}

variable "master_username" {
  type    = string
  default = "realworld"
}

variable "backup_retention_days" {
  description = "Automated backup (PITR) retention."
  type        = number
  default     = 7
}

variable "delete_automated_backups" {
  description = "Delete automated backups when the instance is deleted. When false they are kept until retention expires, so point-in-time restore stays possible."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "performance_insights_enabled" {
  type    = bool
  default = true
}

variable "cloudwatch_logs_exports" {
  description = "Postgres logs exported to CloudWatch."
  type        = list(string)
  default     = []
}
