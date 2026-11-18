output "vpc_id" {
  description = "ID of the application VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Subnet IDs for internet-facing load balancers."
  value       = aws_subnet.public[*].id
}

output "application_subnet_ids" {
  description = "Private subnet IDs for EKS."
  value       = aws_subnet.application[*].id
}

output "database_subnet_ids" {
  description = "Isolated subnet IDs for RDS."
  value       = aws_subnet.database[*].id
}