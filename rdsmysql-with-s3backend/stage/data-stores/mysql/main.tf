terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {

    # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
    # manually, uncomment and fill in the config below.
    profile        = "nova-tf-test"
    bucket         = "mysql-tfstate"
    key            = "service/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "mysql-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "nova-tf-test"
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-nova-test"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  publicly_accessible = true
  db_name             = var.db_name
  username = var.db_username
  password = var.db_password
  vpc_security_group_ids = [aws_security_group.default.id]
}

resource "aws_security_group" "default" {
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["113.200.54.58/32"]
  }
}