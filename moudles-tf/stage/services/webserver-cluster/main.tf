terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "nova-tf-test"
}

module "webserver_cluster" {
  # 最好是将这个source上传到git 使用版本管理起来。例如: "github.com/foo/modules//services/webserver-cluster?ref=v0.0.1" 
  source = "../../../modules/services/webserver-cluster" 

  # (parameters hidden for clarity)

  cluster_name           = var.cluster_name
  db_remote_state_bucket = var.db_remote_state_bucket
  db_remote_state_key    = var.db_remote_state_key

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id # (1)  Use the output variable from the module to get the security group ID  of the ALB

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

