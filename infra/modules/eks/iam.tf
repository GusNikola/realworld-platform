data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.name}-eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  node_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

# Separate roles for the managed node group and Karpenter nodes: EKS creates the
# access entry for a managed node group role itself, Karpenter's needs our own.
resource "aws_iam_role" "system_node" {
  name               = "${var.name}-system-node"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
}

resource "aws_iam_role_policy_attachment" "system_node" {
  for_each = toset(local.node_policy_arns)

  role       = aws_iam_role.system_node.name
  policy_arn = each.value
}

resource "aws_iam_role" "karpenter_node" {
  name               = "${var.name}-karpenter-node"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
}

resource "aws_iam_role_policy_attachment" "karpenter_node" {
  for_each = toset(local.node_policy_arns)

  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}
