terraform {
  backend "s3" {
    bucket       = "inventory-tfstate-e7b1afc0da7dd8de2cb4526e3b"
    key          = "github-actions/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}