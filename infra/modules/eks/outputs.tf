output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes management API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "node_security_group_id" {
  description = "EKS-created security group shared by the control plane and managed workers."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

