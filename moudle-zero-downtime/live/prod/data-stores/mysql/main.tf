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

    bucket         = "novastar-tfstate-1"
    key            = "service/zero-downtime/live/prod/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "nova-tfstate-test"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "nova-tf-test"
}

resource "aws_db_instance" "example" {
  identifier_prefix           = "mysql-rds-test"
  engine                      = "mysql"
  engine_version              = "8.0.28" # 可以指定特定的版本
  allocated_storage           = 10
  instance_class              = "db.t2.micro"
  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  skip_final_snapshot         = true
  parameter_group_name        = "default.mysql8.0"
  allow_major_version_upgrade = true
  publicly_accessible         = true # 允许公网访问
}
