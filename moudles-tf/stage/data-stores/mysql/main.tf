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

    # bucket         = "<YOUR S3 BUCKET>"
    # key            = "<SOME PATH>/terraform.tfstate"
    profile = "nova-tf-test"
    region  = "us-east-2"
    # dynamodb_table = "<YOUR DYNAMODB TABLE>"
    # encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "nova-tf-test"
}

# resource "aws_db_instance" "example" {
#   identifier_prefix           = "terraform-up-and-running"
#   engine                      = "mysql"
#   engine_version              = "8.0.28" # 可以指定特定的版本
#   allocated_storage           = 10
#   instance_class              = "db.t2.micro"
#   db_name                     = var.db_name
#   username                    = var.db_username
#   password                    = var.db_password
#   skip_final_snapshot         = true
#   parameter_group_name        = "default.mysql8.0"
#   allow_major_version_upgrade = true
#   publicly_accessible         = true # 允许公网访问
#   vpc_security_group_ids      = [aws_security_group.default.id]

# }

resource "aws_db_instance" "example" {
  identifier_prefix           = "vnnox-au-withtf"
  engine                      = "mysql"
  engine_version              = "5.7.44" # 可以指定特定的版本
  allocated_storage           = 10
  storage_type                = "gp2"
  instance_class              = "db.t2.micro"
  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  skip_final_snapshot         = true
  parameter_group_name        = "default.mysql5.7"
  allow_major_version_upgrade = true
  publicly_accessible         = true
  vpc_security_group_ids      = [aws_security_group.default.id]
  multi_az                    = true
  backup_retention_period     = 7
  backup_window               = "03:00-06:00"
  maintenance_window          = "Sun:00:00-Sun:03:00"
  auto_minor_version_upgrade  = true
  final_snapshot_identifier   = "mydb-final-snapshot-1"
  deletion_protection         = true
}

# resource "aws_db_instance" "replicas" {
#   identifier             = "mydb-replica"
#   replicate_source_db    = aws_db_instance.example.id
#   instance_class         = "db.t2.micro"
#   multi_az               = false # 只读副本通常不需要 multi_az
#   vpc_security_group_ids = [aws_security_group.default.id]
# publicly_accessible         = true
# }


resource "random_string" "snap_suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "default" {
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["113.200.54.58/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
