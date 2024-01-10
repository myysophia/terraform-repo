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

# 命令
terraform init
terraform apply
terraform destroy
