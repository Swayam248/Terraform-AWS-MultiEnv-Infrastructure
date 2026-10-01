terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["terraform-multienv-vpc"]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["terraform-multienv-public-subnet"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "web" {
  filter {
    name   = "tag:Name"
    values = ["terraform-multienv-web-sg"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_key_pair" "ec2" {
  key_name = "terraform-multienv-ec2-key"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id                      = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id
  security_group_id           = data.aws_security_group.web.id
  key_name                    = data.aws_key_pair.ec2.key_name
  associate_public_ip_address = true
  name                        = "terraform-multienv-${var.environment}-web"
}