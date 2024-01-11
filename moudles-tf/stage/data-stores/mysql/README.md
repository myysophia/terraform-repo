# 为mysql指定版本并更新
lifecycle 对其的影响

这个创建的mysql 版本是5.7.44
```
resource "aws_db_instance" "example" {
  engine_version       = "5.7"
  parameter_group_name = "default.mysql5.7"
}
```
不加lifecycle，更换版本

```
resource "aws_db_instance" "example" {
  engine_version       = "8.0"
  parameter_group_name = "default.mysql5.7"
}
```
# 问题点

【1】使用bucket 报错
引入global 创建bucket 和 dynamicDB table_name

```
dynamodb_table_name = "mysql57-tfstate-lock"
s3_bucket_arn = "arn:aws:s3:::mysql57-tfstate"
```

这个报错是输入了一个已经存在的bucket，无法创建。
```
 Failed to get existing workspaces: Unable to list objects in S3 bucket "mysql57": operation error S3: ListObjectsV2, https response error StatusCode: 301, RequestID: B0RA34Y0QJGAZ3Y3, HostID: 4ztxlv8z65K9xLCEmlwK78oQf0IhZf/j+uRdG/Op57yyxb0uagWtzWsd3pIH5QTetOOrknFnxcQ=, requested bucket from "us-east-2", actual location "us-west-2
```