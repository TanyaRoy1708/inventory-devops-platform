output "instance_id" {
  description = "EC2 instance ID for Systems Manager access"
  value       = aws_instance.runner.id
}

output "private_ip" {
  description = "Private IP address of the deployment runner"
  value       = aws_instance.runner.private_ip
}