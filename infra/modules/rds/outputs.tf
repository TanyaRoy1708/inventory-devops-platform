output "address" {
  description = "Private PostgreSQL hostname."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "PostgreSQL connection port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN identifying the administrator credential secret."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}