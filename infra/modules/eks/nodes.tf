resource "aws_eks_node_group" "application" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = ["t3.medium"]
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  scaling_config {
    min_size     = 1
    desired_size = 1
    max_size     = 2
  }

  depends_on = [aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_ecr,
  aws_iam_role_policy_attachment.node_cni, ]
}