resource "aws_key_pair" "ec2" {
  key_name   = "${local.project_name}-ec2-key"
  public_key = file("C:/Users/Arpan/.ssh/terraform-ec2.pub")
}