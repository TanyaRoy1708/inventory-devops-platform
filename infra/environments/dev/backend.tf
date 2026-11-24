terraform {
  backend "s3" {
    bucket       = "inventory-tfstate-23e73f43f013d5bff3a7acf0b0"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}