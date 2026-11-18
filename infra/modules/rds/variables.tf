variable "identifier" {
  description = "Name of the RDS database instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the database"
  type        = string
}

variable "subnet_ids" {
  description = "Security group whose members may connect to postgresql"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group whose members may connect to PostgreSQL."
  type        = string
}