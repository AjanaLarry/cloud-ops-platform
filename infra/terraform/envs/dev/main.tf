# ──────────────────────────────────────────────────────────
# DEV ENVIRONMENT
# Calls all 5 modules and passes outputs between them
# ──────────────────────────────────────────────────────────

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "juwon"
    }
  }
}

data "aws_caller_identity" "current" {}

# ── 1. Networking ─────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["ca-central-1a", "ca-central-1b"]
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── 2. Security ───────────────────────────────────────────
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── 3. Compute ────────────────────────────────────────────
module "compute" {
  source = "../../modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  subnet_id             = module.networking.public_subnet_ids[0]
  security_group_id     = module.security.ec2_sg_id
  instance_profile_name = module.security.ec2_instance_profile_name
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── 4. Storage ────────────────────────────────────────────
module "storage" {
  source = "../../modules/storage"

  project_name       = var.project_name
  environment        = var.environment
  aws_account_id     = data.aws_caller_identity.current.account_id
  private_subnet_ids = module.networking.private_subnet_ids
  rds_sg_id          = module.security.rds_sg_id
  db_password        = var.db_password
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── 5. Monitoring ─────────────────────────────────────────
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  instance_id  = module.compute.instance_id
  alert_email  = var.alert_email
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Outputs ───────────────────────────────────────────────
output "vpc_id"          { value = module.networking.vpc_id }
output "ec2_public_ip"   { value = module.compute.public_ip }
output "rds_endpoint"    { value = module.storage.rds_endpoint }
output "s3_bucket"       { value = module.storage.s3_bucket_id }
output "sns_topic_arn"   { value = module.monitoring.sns_topic_arn }
