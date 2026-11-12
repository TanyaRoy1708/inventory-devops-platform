terraform {
  backend "s3" {
    bucket       = "inventory-tfstate-872ff07c7a6a1293f4af104c18"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}