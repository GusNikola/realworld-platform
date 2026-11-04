data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# SSM access only. CI jobs on the runner get AWS permissions through GitHub OIDC,
# never from the instance profile.
resource "aws_iam_role" "this" {
  name               = "${var.name}-ops-host"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-ops-host"
  role = aws_iam_role.this.name
}

resource "aws_security_group" "this" {
  name        = "${var.name}-ops-host"
  description = "Ops host and GitHub runner, egress only"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-ops-host"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Outbound to SSM, GitHub, AWS APIs and the EKS endpoint"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name

  user_data_base64 = base64encode(templatefile("${path.module}/user-data.sh.tftpl", {
    runner_version = var.runner_version
    runner_sha256  = var.runner_sha256
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.name}-ops-host"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
