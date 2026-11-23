resource "aws_security_group" "runner" {
  name_prefix = "${var.name_prefix}-runner-"
  description = "Deployment runner managed through AWS Systems Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-runner"
  }
}

# the runner needs outbound HTTPS to GitHub, Ubuntu, and AWS.
# Destination filtering through an egress proxy/firewall is deferred.
#trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.runner.id
  description       = "HTTPS access to GitHub, AWS services, and EKS"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_api" {
  security_group_id = var.eks_cluster_security_group_id
  description       = "Allow runner to reach the private EKS API"

  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.runner.id
}