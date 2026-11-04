module "rds" {
  source = "../../../modules/rds"

  name       = local.name
  vpc_id     = local.network.vpc_id
  subnet_ids = local.network.data_subnet_ids

  # Managed and Karpenter nodes both use the cluster security group; the ops host
  # is allowed for maintenance (psql through an SSM session).
  allowed_security_groups = {
    eks      = module.eks.cluster_security_group_id
    ops_host = module.ops_host.security_group_id
  }

  instance_class = "db.t4g.micro"
  multi_az       = false

  backup_retention_days        = 1
  delete_automated_backups     = true
  deletion_protection          = false
  skip_final_snapshot          = true
  performance_insights_enabled = false
}
