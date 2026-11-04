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
  multi_az       = true

  backup_retention_days        = 14
  deletion_protection          = true
  skip_final_snapshot          = false
  performance_insights_enabled = true
  cloudwatch_logs_exports      = ["postgresql", "upgrade"]
}

# Cross-region disaster recovery: replicate automated backups (snapshots and
# transaction logs) to us-west-2 for point-in-time restore there.
# Disabled because the organization's service control policy denies every region
# except us-east-1, so neither the replication nor the destination KMS key can be
# created. To enable, restore the "dr" provider alias in providers.tf and uncomment.
#
# data "aws_kms_key" "rds_dr" {
#   provider = aws.dr
#   key_id   = "alias/aws/rds"
# }
#
# resource "aws_db_instance_automated_backups_replication" "dr" {
#   provider = aws.dr
#
#   source_db_instance_arn = module.rds.instance_arn
#   kms_key_id             = data.aws_kms_key.rds_dr.arn
#   retention_period       = 14
# }
