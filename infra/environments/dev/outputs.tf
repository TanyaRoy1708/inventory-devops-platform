output "vpc_id" {
  description = "Development VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Development public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "application_subnet_ids" {
  description = "Development private application subnet IDs."
  value       = module.network.application_subnet_ids
}

output "database_subnet_ids" {
  description = "Development isolated database subnet IDs."
  value       = module.network.database_subnet_ids
}

output "ecr_repository_url" {
  description = "Development application image repository URL."
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "Development ECR repository ARN."
  value       = module.ecr.repository_arn
}

output "ecr_repository_name" {
  description = "Development ECR repository name."
  value       = module.ecr.repository_name
}

output "eks_cluster_name" {
  description = "Development EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes management API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_node_security_group_id" {
  description = "EKS security group shared by the control plane and workers."
  value       = module.eks.node_security_group_id
}

output "kubeconfig_command" {
  description = "Command to configure kubectl after creating the cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
output "db_host" {
  description = "Private PostgreSQL hostname."
  value       = module.rds.address
}

output "db_port" {
  description = "PostgreSQL connection port."
  value       = module.rds.port
}

output "db_name" {
  description = "Application database name."
  value       = module.rds.database_name
}

output "db_admin_secret_arn" {
  description = "ARN of the administrator credential secret."
  value       = module.rds.master_user_secret_arn
}