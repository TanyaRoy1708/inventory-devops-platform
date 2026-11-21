variable "aws_region" {
  description = "AWS region containing the ECR repository"
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_owner_id" {
  description = "Numeric GitHub repository owner ID"
  type        = string
}

variable "github_repository_id" {
  description = "Numeric GitHub repository ID"
  type        = string
}

variable "github_branch" {
  description = "Branch allowed to assume the publishing role"
  type        = string
  default     = "main"
}

variable "ecr_repository_name" {
  description = "ECR repository to which the role can push images"
  type        = string
}

variable "role_name" {
  description = "Name of the GitHub Actions IAM role"
  type        = string
}