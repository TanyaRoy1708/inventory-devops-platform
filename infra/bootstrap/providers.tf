provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "inventory-devops-platform"
      ManagedBy = "Terraform"
      Component = "state-backend"
    }
  }
}