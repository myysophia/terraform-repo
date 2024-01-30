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
    key            = "service/zero-downtime/live/stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "nova-tfstate-test"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "nova-tf-test"  
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "mysql-rds-test"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
}
