# Remote state — replace bucket name with your own S3 bucket
# Create the S3 bucket and DynamoDB table manually first (Week 2)
terraform {
  backend "s3" {
    bucket         = "cloud-ops-platform-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "cloud-ops-platform-tfstate-lock"
    encrypt        = true
  }
}
