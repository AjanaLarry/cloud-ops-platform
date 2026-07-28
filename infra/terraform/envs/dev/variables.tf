variable "project_name" {
  type    = string
  default = "cloud-ops-platform"
}

variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "alert_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
}

variable "db_password" {
  description = "RDS master password — sensitive, never logged"
  type        = string
  sensitive   = true
}
