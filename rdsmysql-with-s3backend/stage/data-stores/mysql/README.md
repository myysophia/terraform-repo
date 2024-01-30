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
terraform console中查看 特定资源的属性  aws_security_group.default.id
![image](https://github.com/myysophia/terraform-repo/assets/25994521/ab0a62eb-2a38-4cbc-9054-a72e9509643e)

# mysql 如何升级？
修改aws_db_instance的engine_version。 实际上是无法做到原地升级的，尽管terraform apply返回成功。
数据库升级应该考虑数据的备份与恢复、停机时间、兼容性...。

![image](https://github.com/myysophia/terraform-repo/assets/25994521/ce7ae5bb-af49-43cb-a31c-e693dbbc3769)


# 创建高可用集群
- 多AZ高可用
- 多AZ集群
![企业微信截图_17050494832996](https://github.com/myysophia/terraform-repo/assets/25994521/31d226e4-e708-4296-8f20-c52214bddcf3)
1. terraform 代码
```
resource "aws_db_instance" "example" {
  identifier_prefix           = "terraform-up-and-running"
  engine                      = "mysql"
  engine_version              = "8.0.28" # 可以指定特定的版本
  allocated_storage           = 10
  storage_type                = "gp2"
  instance_class              = "db.t2.micro"
  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  skip_final_snapshot         = true
  parameter_group_name        = "default.mysql8.0"
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

resource "aws_db_instance" "replicas" {
  identifier             = "mydb-replica"
  replicate_source_db    = aws_db_instance.example.id
  instance_class         = "db.t2.micro"
  multi_az               = false # 只读副本通常不需要 multi_az
  vpc_security_group_ids = [aws_security_group.default.id]
}
```
2. terraform apply大概需要14 + 9mins
   ![image](https://github.com/myysophia/terraform-repo/assets/25994521/85f3ded7-bba8-47e1-a41b-a57274b849ff)


# 命令
terraform init

terraform apply

terraform destroy
