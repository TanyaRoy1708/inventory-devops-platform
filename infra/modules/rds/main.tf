resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    name = "${var.identifier}-subnets"
  }
}

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = "postgres"
  engine_version = "17"
  instance_class = "db.t4g.micro"

  db_name                     = "inventory_db"
  username                    = "inventory_admin"
  manage_master_user_password = true

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false
  multi_az               = false

  # Disposable lab: retain no database backups when the instance is destroyed.
  backup_retention_period  = 0
  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true
}
