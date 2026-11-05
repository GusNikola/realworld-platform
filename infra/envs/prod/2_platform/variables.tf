variable "cluster_endpoint_override" {
  description = "Local end of an SSM port-forward to the private EKS endpoint (e.g. https://localhost:8443). Leave null when running inside the VPC (self-hosted runner)."
  type        = string
  default     = null
}

variable "gitops_revision" {
  description = "Git revision of realworld-platform that ArgoCD syncs from."
  type        = string
  default     = "main"
}
