variable "project_name" {
  description = "Name prefix used for all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev, staging, or prod"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Two AZs to deploy subnets into"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "common_tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
