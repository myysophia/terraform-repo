# 注意点
【1】mysql 的账密配置
可以在variable 给出default值，推荐使用环境变量并在variables中设置sensitive
```
export TF_VAR_db_username=root
export TF_VAR_db_password=123456
```
# 命令
terraform init
terraform apply
terraform destroy
