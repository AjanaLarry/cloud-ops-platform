variable "project_name"  { type = string }
variable "environment"   { type = string }
variable "instance_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}
variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
