# Terraform Block
terraform {
  backend "s3" {
    bucket  = "mayank-terraform-state-file"
    key     = "new-state/terraform.tfstate"
    region  = "us-east-1"
  }
  required_version = "~>1.1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.72.0"
    }
  }

}
# Provider Block 
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_instance" "terraform-publc-instance" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"
  key_name      = "terraform-key"
  count		= 1
  user_data     = <<-EOF
     #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    echo "<h1>AWS Infra created using Terraform in us-east-1 Region</h1>" > /var/www/html/index.html
    sudo systemctl enable httpd
    sudo systemctl start httpd
    EOF
  tags = {
    Name = "terraform"
  }
}

data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
