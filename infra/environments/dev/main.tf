data "aws_availability_zones" "available" {
  state = "available"

  exclude_zone_ids = ["use1-az3"]

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix        = var.name_prefix
  vpc_cidr           = "10.20.0.0/16"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.name_prefix
  force_delete    = var.ecr_force_delete
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                = var.name_prefix
  kubernetes_version          = var.kubernetes_version
  subnet_ids                  = module.network.application_subnet_ids
  public_access_cidrs         = var.eks_public_access_cidrs
  cluster_admin_principal_arn = var.eks_cluster_admin_principal_arn
  depends_on                  = [module.network]
}

module "rds" {
  source = "../../modules/rds"

  identifier                = "${var.name_prefix}-postgres"
  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.database_subnet_ids
  allowed_security_group_id = module.eks.node_security_group_id
}
