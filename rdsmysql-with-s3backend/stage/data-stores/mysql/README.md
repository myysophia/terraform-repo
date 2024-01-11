# 注意点
【1】mysql 的账密配置
可以在variable 给出default值，推荐使用环境变量并在variables中设置sensitive
```
export TF_VAR_db_username=root
export TF_VAR_db_password=12345678
```

【2】不指定版本，默认是8的最新版本的,在tf state中可以看到
```
"engine_version_actual": "8.0.35",
```
【3】如何连接mysql rds
```
Outputs:

address = "terraform-up-and-running20240110133953647200000001.criagiq2we20.us-east-2.rds.amazonaws.com"
port = 3306

```
【4】默认是只有vpc内可以连接，如何外部访问呢？

```
resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-test"

  publicly_accessible = true

}
```
还是原来的地址, publicly_accessible代表外部可访问，前提是放行对应的安全组。
```
terraform-up-and-running20240110133953647200000001.criagiq2we20.us-east-2.rds.amazonaws.com 3306

```

【5】创建的实例如何关联安全组？
```
resource "aws_db_instance" "example" {
...
  # 在aws_db_instance 中进行关联
  vpc_security_group_ids = [aws_security_group.default.id]
}
# 定义可以访问mysql的安全组
resource "aws_security_group" "default" {
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.10.10.10/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

# 命令
terraform init

terraform apply

terraform destroy
