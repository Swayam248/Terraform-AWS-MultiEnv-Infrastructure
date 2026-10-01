variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group to attach to the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}