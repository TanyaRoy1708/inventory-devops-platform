variable "name_prefix" {
  description = "Prefix for deployment runner resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the deployment runner"
  type        = string
}

variable "subnet_id" {
  description = "Private application subnet for the deployment runner"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "EKS security group to allow API access from the runner"
  type        = string
}