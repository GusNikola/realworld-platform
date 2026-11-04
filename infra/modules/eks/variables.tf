variable "name" {
  description = "Cluster name, also used as the prefix for related resources."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for the control plane ENIs and the system node group."
  type        = list(string)
}

variable "cluster_log_types" {
  description = "Control plane log types sent to CloudWatch. Empty list disables control plane logging."
  type        = list(string)
  default     = []
}

variable "cluster_log_retention_days" {
  description = "Retention of the control plane log group."
  type        = number
  default     = 30
}

variable "admin_principal_arns" {
  description = "IAM role/user ARNs granted cluster admin through access entries."
  type        = list(string)
  default     = []
}

variable "system_node_instance_types" {
  description = "Instance types of the system managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "system_node_capacity_type" {
  description = "ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.system_node_capacity_type)
    error_message = "Must be ON_DEMAND or SPOT."
  }
}

variable "system_node_min_size" {
  type    = number
  default = 2
}

variable "system_node_desired_size" {
  type    = number
  default = 2
}

variable "system_node_max_size" {
  type    = number
  default = 3
}

variable "system_node_disk_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 20
}
