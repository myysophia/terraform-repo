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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration
resource "aws_launch_configuration" "example" {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World,NOVATFTEST WEBSERVER CLUSTER" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }              
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag{
    key = "Name"
    value = "terraform-example-asg"
    propagate_at_launch = true
  
  }
}

resource "aws_security_group" "instance" {
  name = var.instance_security_group_name

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
  
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "example" {
  name = var.alb_name

  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn # 在哪个负载均衡器上创建监听器
  port = 80
  protocol = "HTTP"

  default_action { # 默认的行为
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = "404"
    }
  } 
}

resource "aws_lb_target_group" "asg" { 
  name = "terraform-example-asg" # aws_autoscaling_group 的名称，将负载均衡器和自动扩展组关联起来，负载均衡器会将请求转发到目标组中的实例。 弹性和可伸缩体现在这里。
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  target_type = "instance"
  health_check { # LB的健康检查规则
    port = 8080
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn # 给监听器添加规则，规则的作用是将请求转发到目标组中的实例，action是什么？转到哪里？
  priority = 100

  condition {
    path_pattern {
      values = ["*"] # 匹配所有的请求, *表示通配符，可以是/api/*。
    }
  }
  action {
    type = "forward" # redirect，重定向
    target_group_arn = aws_lb_target_group.asg.arn # 关联到目标组 terraform-example-asg
  }
}

resource "aws_security_group" "alb" {
  name = var.alb_security_group_name
  # Allow inbond HTTP request from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.50.10.10/32"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["113.200.58.54/32"]
  }
  # Allow all outbond requests
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}