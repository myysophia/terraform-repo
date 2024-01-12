# Web server cluster module 
模版将变量抽象出来，给不同环境使用。
```
data "terraform_remote_state" "db" {
 backend = "s3"
 config = {
 bucket = var.db_remote_state_bucket
 key = var.db_remote_state_key
 region = "us-east-2"
 }
}

```

# 局部变量
有些变量相对固定，变化并不频繁可以使用local 变量。局部变量使代码更容易阅读和维护，所以要经常使用它们。
```
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}
```

# 问题点(gotchas)
【1】 外部脚本引用的路径问题
在模版中尽可能使用绝对路径而不是相对路径，使用path.module获取当前
path.module: Returns the filesystem path of the module where the expression is defined.
path.root: Returns the filesystem path of the root module.
根据你的目录结构来进行选择
```
resource "aws_launch_configuration" "example" {
  ...
  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })
  ...
}
```
【2】创建resource时使用内联模块还是单模块
什么是内联模块?
模块中嵌套模块，这中方式不推荐使用，因为这种在moudle中无法使用for each新增。
```
resource "aws_security_group" "alb" {
  name = var.alb_security_group_name

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
什么是单模块？
单模块的优势是灵活，当有多个安全组时，可以使用循环变量外部变量批量渲染安全组规则。
```
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}
```

You should also export the ID of the aws_security_group as an output variable in modules/services/webserver-cluster/outputs.tf:
```
output "alb_security_group_id" {
 value = aws_security_group.alb.id
 description = "The ID of the Security Group attached to the load balancer"
}
```
这样在stage 或者prod中需要开放哪个安全组，直接引用这个alb_security_group_id
```
resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id # (1)  Use the output variable from the module to get the security group ID  of the ALB

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```
类似的内联资源还有
```
aws_security_group and aws_security_group_rule
aws_route_table and aws_route
aws_network_acl and aws_network_acl_rule
```
