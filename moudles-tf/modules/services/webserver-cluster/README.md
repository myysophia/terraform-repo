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