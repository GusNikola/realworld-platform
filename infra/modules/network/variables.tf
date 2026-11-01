variable "name" {
  description = "Name prefix for all resources, e.g. realworld-prod."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across. EKS and RDS require at least two."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnets (ALB, NAT gateways), one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "Provide exactly one public subnet CIDR per availability zone."
  }
}

variable "app_subnet_cidrs" {
  description = "Private application subnets (EKS nodes and pods), one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_cidrs) == length(var.azs)
    error_message = "Provide exactly one app subnet CIDR per availability zone."
  }
}

variable "data_subnet_cidrs" {
  description = "Private data subnets (RDS) with no route to the internet, one per AZ."
  type        = list(string)

  validation {
    condition     = length(var.data_subnet_cidrs) == length(var.azs)
    error_message = "Provide exactly one data subnet CIDR per availability zone."
  }
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ. Cheaper, but the NAT AZ becomes a single point of failure for egress."
  type        = bool
  default     = false
}

variable "interface_endpoints" {
  description = "AWS services to expose through interface VPC endpoints in every app subnet, e.g. [\"secretsmanager\"]."
  type        = list(string)
  default     = []
}

variable "interface_endpoint_policies" {
  description = "Optional endpoint policy JSON per service in interface_endpoints. Services without an entry get the AWS default (full access)."
  type        = map(string)
  default     = {}
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Retention of the flow logs log group."
  type        = number
  default     = 30
}

variable "public_subnet_tags" {
  description = "Extra tags for public subnets."
  type        = map(string)
  default     = {}
}

variable "app_subnet_tags" {
  description = "Extra tags for app subnets."
  type        = map(string)
  default     = {}
}
