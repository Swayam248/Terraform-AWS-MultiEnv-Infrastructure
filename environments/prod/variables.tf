variable "aws_region" {
  description = "AWS region for the Production environment"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for Production"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}