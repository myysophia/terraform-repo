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
【2】mysql 版本升级

```
 Error: updating RDS DB Instance (terraform-up-and-running20240111085855598600000001): operation error RDS: ModifyDBInstance, https response error StatusCode: 400, RequestID: 18af0b9e-eb02-4fd0-a8b0-04874a6776af, api error InvalidParameterCombination: The AllowMajorVersionUpgrade flag must be present when upgrading to a new major version.

```
增加allow_major_version_upgrade = true，报错
```
Error: updating RDS DB Instance (terraform-up-and-running20240111085855598600000001): operation error RDS: ModifyDBInstance, https response error StatusCode: 404, RequestID: 8294289a-c53e-400c-95dc-7684934a964a, DBParameterGroupNotFound: DBParameterGroup not found: default:mysql-8.0
```