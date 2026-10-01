output "vpc_id" {
  description = "ID of the Terraform-managed VPC"
  value       = aws_vpc.main.id
}

output "availability_zones" {
  description = "Available AWS Availability Zones"
  value       = data.aws_availability_zones.available.names
}