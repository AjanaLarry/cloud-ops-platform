variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID — received from networking module output"
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
