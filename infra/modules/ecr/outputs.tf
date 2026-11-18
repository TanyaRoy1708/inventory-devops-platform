output "repository_url" {
  description = "Repository URL used to push and pull container images."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "Repository ARN used in IAM permissions."
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.this.name
}