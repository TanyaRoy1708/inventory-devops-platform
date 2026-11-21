provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "inventory-devops-platform"
      Component = "github-actions"
      ManagedBy = "Terraform"
    }
  }
}