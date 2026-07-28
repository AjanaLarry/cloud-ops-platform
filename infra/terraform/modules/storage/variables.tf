variable "project_name"  { type = string }
variable "environment"   { type = string }
variable "aws_account_id" {
  description = "AWS account ID — used to make S3 bucket name globally unique"
  type        = string
}
variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}
variable "rds_sg_id" {
  description = "RDS security group ID"
  type        = string
}
variable "db_password" {
  description = "RDS master password — marked sensitive, never logged"
  type        = string
  sensitive   = true
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
