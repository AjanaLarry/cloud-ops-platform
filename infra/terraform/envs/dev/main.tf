provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cloud-ops-platform"
      Environment = "dev"
      ManagedBy   = "terraform"
      Owner       = "juwon"
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["ca-central-1a", "ca-central-1b"]

  common_tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
