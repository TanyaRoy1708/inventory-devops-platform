output "github_ecr_push_role_arn" {
  description = "IAM role ARN used by GitHub Actions to publish inventory images"
  value       = aws_iam_role.github_ecr_push.arn
}