variable "aws_region" {
  description = "AWS region for the Staging environment"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for Staging"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}