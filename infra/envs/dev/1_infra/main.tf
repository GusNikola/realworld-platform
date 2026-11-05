locals {
  name = "realworld-dev"
}

module "eks" {
  source = "../../../modules/eks"

  name               = local.name
  kubernetes_version = "1.37"
  subnet_ids         = local.network.app_subnet_ids

  cluster_log_types = []

  admin_principal_arns = [data.terraform_remote_state.bootstrap.outputs.terraform_apply_role_arn]

  system_node_instance_types = ["t3.medium", "t3a.medium"]
  system_node_capacity_type  = "SPOT"
  system_node_min_size       = 1
  system_node_desired_size   = 1
  system_node_max_size       = 2
}

module "ecr" {
  source = "../../../modules/ecr"

  name         = local.name
  components   = ["backend", "frontend"]
  force_delete = true
}

module "ops_host" {
  source = "../../../modules/ops-host"

  name      = local.name
  vpc_id    = local.network.vpc_id
  subnet_id = local.network.app_subnet_ids[0]

  runner_version = "2.338.2"
  runner_sha256  = "baebf204307bac6193480852732f0aba2ae97b6c5597c244f4d5558390147c40"
}

resource "aws_vpc_security_group_ingress_rule" "ops_host_to_cluster" {
  security_group_id            = module.eks.cluster_security_group_id
  description                  = "Kubernetes API from the ops host"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = module.ops_host.security_group_id
}

module "waf" {
  source = "../../../modules/waf"

  name = local.name
}
