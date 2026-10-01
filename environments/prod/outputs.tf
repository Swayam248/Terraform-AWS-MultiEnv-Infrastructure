output "instance_id" {
  description = "Production EC2 instance ID"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Production EC2 public IP"
  value       = module.ec2.public_ip
}

output "private_ip" {
  description = "Production EC2 private IP"
  value       = module.ec2.private_ip
}

output "public_dns" {
  description = "Production EC2 public DNS"
  value       = module.ec2.public_dns
}