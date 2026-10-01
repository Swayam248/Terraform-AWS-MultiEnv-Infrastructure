output "vpc_id" {
  description = "ID of the Terraform-managed VPC"
  value       = aws_vpc.main.id
}