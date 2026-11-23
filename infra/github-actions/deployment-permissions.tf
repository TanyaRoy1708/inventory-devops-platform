data "aws_iam_policy_document" "eks_deploy" {
  statement {
    sid     = "DescribeDeploymentCluster"
    effect  = "Allow"
    actions = ["eks:DescribeCluster"]

    resources = [
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
    ]
  }
}

resource "aws_iam_role_policy" "eks_deploy" {
  name   = "eks-deployment"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.eks_deploy.json
}