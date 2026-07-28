# ──────────────────────────────────────────────────────────
# SECURITY MODULE
# Creates: EC2 security group, RDS security group,
#          IAM role + instance profile for EC2
# ──────────────────────────────────────────────────────────

# ── EC2 Security Group ────────────────────────────────────
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg-${var.environment}"
  description = "EC2 app server - HTTP, HTTPS, SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere - restrict to your IP in production"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-sg-${var.environment}"
  })
}

# ── RDS Security Group ────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "RDS PostgreSQL - allow 5432 from EC2 SG only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EC2 security group only - SG chaining"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-rds-sg-${var.environment}"
  })
}

# ── IAM Role for EC2 ──────────────────────────────────────
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.project_name}-ec2-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-role-${var.environment}"
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile-${var.environment}"
  role = aws_iam_role.ec2.name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-profile-${var.environment}"
  })
}
