# 问题点
【1】web-cluster 如何读取数据库的连接？
读取mysql 的terraform state，state中存储执行的细节，包括数据库的连接信息、版本、规模....。
web-cluster中使用data属性从外部读取数据，示例如下
```
# you can get the web serverto read datasource-mysql outputs from the database’s state file of s3 backend
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    profile        = "nova-tf-test"
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-2"
  }
}
```
用户数据使用一段脚本来渲染去读取data的内容，打印出数据库的连接地址和端口
```
 # Render the User Data script as a template
  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })
```
【2】读取db_remote_state_bucket 和 db_remote_state_key
这两个变量如果没有默认值

# 命令
terraform init
terraform apply
terraform destroy

# 输出
```
 curl -i http://terraform-asg-example-1865963883.us-east-2.elb.amazonaws.com/
HTTP/1.1 200 OK
Date: Thu, 11 Jan 2024 01:16:47 GMT
Content-Type: text/html
Content-Length: 183
Connection: keep-alive
Accept-Ranges: bytes
Last-Modified: Wed, 10 Jan 2024 14:13:59 GMT

<h1>Hello, World, NOVA RDS TEST WITH TFSTATE </h1>
<p>DB address: terraform-up-and-running20240110133953647200000001.criagiq2we20.us-east-2.rds.amazonaws.com</p>
<p>DB port: 3306</p>

```
![image](https://github.com/myysophia/terraform-repo/assets/25994521/8b1b89a1-f9bc-4589-8c66-89ddec7fae1b)


# 架构

![image](https://github.com/myysophia/terraform-repo/assets/25994521/fea39a8a-0ad4-44d6-aff0-2a2cdf12b367)
