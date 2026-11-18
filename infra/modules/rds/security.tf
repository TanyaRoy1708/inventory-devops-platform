resource "aws_security_group" "database" {
  name        = "${var.identifier}-database-sg"
  description = "Controls incoming Postgresql connections"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.identifier}-database-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_eks" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = var.allowed_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}