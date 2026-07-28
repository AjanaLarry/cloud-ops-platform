terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cloud-ops-platform-tfstate-larry-kodes"
    key            = "dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "cloud-ops-platform-tfstate-lock"
    encrypt        = true
  }
}
