variable "aws_region" {
  description = "AWS region; the state backend region is configured separately."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for development resource names."
  type        = string
  default     = "inventory-dev"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.name_prefix))
    error_message = "name_prefix must be 3-31 characters: lowercase letters, digits, and hyphens, starting with a letter."
  }
}

variable "eks_cluster_admin_principal_arn" {
  description = "Stable IAM user or IAM role ARN, not an STS assumed-role session ARN."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:(user|role)/.+$", var.eks_cluster_admin_principal_arn))
    error_message = "Provide an IAM user or role ARN (arn:aws:iam::<account-id>:user/... or :role/...), not an assumed-role session ARN."
  }
}

variable "eks_public_access_cidrs" {
  description = "Trusted public IPv4 CIDRs for Kubernetes API access; normally your IP/32."
  type        = list(string)

  validation {
    condition     = length(var.eks_public_access_cidrs) > 0 && alltrue([for cidr in var.eks_public_access_cidrs : can(cidrhost(cidr, 0)) && cidr != "0.0.0.0/0"])
    error_message = "Provide at least one valid IPv4 CIDR; 0.0.0.0/0 is not allowed for the Kubernetes API."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version; recheck standard support before provisioning."
  type        = string
  default     = "1.36"

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use the major.minor format, for example 1.36."
  }
}



variable "ecr_force_delete" {
  description = "Allow deleting a nonempty ECR repository only for deliberate teardown."
  type        = bool
  default     = false
}
