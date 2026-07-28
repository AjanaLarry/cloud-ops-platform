# ──────────────────────────────────────────────────────────
# STORAGE MODULE
# Creates: S3 bucket (versioning + lifecycle + encryption)
#          RDS PostgreSQL (private subnet, free tier)
# ──────────────────────────────────────────────────────────

# ── S3 Bucket ─────────────────────────────────────────────
resource "aws_s3_bucket" "app_assets" {
  bucket        = "${var.project_name}-app-assets-${var.aws_account_id}"
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-app-assets"
  })
}

resource "aws_s3_bucket_versioning" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket                  = aws_s3_bucket.app_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  rule {
    id     = "archive-to-glacier"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 7
      storage_class   = "GLACIER"
    }
  }
}

# ── RDS DB Subnet Group ───────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-subnet-group-${var.environment}"
  })
}

# ── RDS PostgreSQL Instance ───────────────────────────────
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-postgres-${var.environment}"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  storage_encrypted      = true
  db_name                = "cloudopsdb"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  multi_az               = false
  backup_retention_period    = 7
  auto_minor_version_upgrade = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-postgres-${var.environment}"
  })
}
