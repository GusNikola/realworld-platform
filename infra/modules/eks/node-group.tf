resource "aws_launch_template" "system" {
  name_prefix = "${var.name}-system-"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    # Hop limit 1 keeps pods (one hop further) away from the node role credentials.
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.system_node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-system"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.name}-system"
    }
  }
}

resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "system"
  node_role_arn   = aws_iam_role.system_node.arn
  subnet_ids      = var.subnet_ids

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = var.system_node_capacity_type
  instance_types = var.system_node_instance_types

  launch_template {
    id      = aws_launch_template.system.id
    version = aws_launch_template.system.latest_version
  }

  scaling_config {
    min_size     = var.system_node_min_size
    desired_size = var.system_node_desired_size
    max_size     = var.system_node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "node-role" = "system"
  }

  # Only pods tolerating this taint (cluster add-ons, Karpenter, ArgoCD) land here.
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Nodes need the CNI (with prefix delegation) and kube-proxy before they can join.
  depends_on = [
    aws_iam_role_policy_attachment.system_node,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
  ]
}
