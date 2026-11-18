variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Private application subnet IDs for EKS."
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "Public IP range allowed to reach the kubernetes API"
  type        = list(string)
}

variable "cluster_admin_principal_arn" {
  description = "Existing IAM user or role ARN granted Kubernetes adminstrator access."
  type        = string
}