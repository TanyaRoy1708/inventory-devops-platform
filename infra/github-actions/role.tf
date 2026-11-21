resource "aws_iam_role" "github_ecr_push" {
  name = var.role_name

  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  description = "Allow inventory GitHub Actions to publish images to ECR"
}