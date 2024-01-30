# 部署mysql注意事项
1. 导出变量
```
export TF_VAR_db_username=(desired database username)
export TF_VAR_db_password=(desired database password)
```
2. 填写bucket、path和dynamicDB lock KEY
这里为何不能用变量呢？？？？
path 不用事先创建，直接写状态存储的路径会自动创建。

可以使用  terraform-repo\moudles-tf\global\s3 创建bucket 和 dynamicDB lock KEY

3. 部署
```
terraform init
terraform apply
terraform destroy
```