# 知识点
【1】资源创建与销毁的顺序，如何保证最小的停机时间以及做到平滑迁移。
```
resource "aws_instance" "example" {
  lifecycle {
    create_before_destroy = true
  }
}



# 问题
