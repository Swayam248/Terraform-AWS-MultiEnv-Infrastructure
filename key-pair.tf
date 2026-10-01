resource "aws_key_pair" "ec2" {
  key_name   = "${local.project_name}-ec2-key"
  public_key = var.ec2_public_key
}