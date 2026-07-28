variable "project_name" { type = string }
variable "environment"  { type = string }

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  description = "Public subnet ID to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "EC2 security group ID"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
