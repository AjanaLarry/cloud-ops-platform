# ──────────────────────────────────────────────────────────
# COMPUTE MODULE
# Creates: EC2 instance with nginx, key pair
# ──────────────────────────────────────────────────────────

# Fetch the latest Amazon Linux 2023 AMI automatically
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair — references the public key you generate locally
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key-${var.environment}"
  public_key = file("~/.ssh/cloud-ops-platform-key.pub")

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-key-${var.environment}"
  })
}

# EC2 instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = aws_key_pair.main.key_name

  user_data = file("${path.module}/user_data.sh")

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-${var.environment}"
  })
}
