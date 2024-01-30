# 传统方式的零宕机
## 0. 需要先部署mysql，并将状态存储在S3中
部署mysql时可以设置默认值也可以apply的时候输入
```hcl
variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket used for the database's remote state storage"
  type        = string
  default     = "<YOUR BUCKET NAME>"
}

variable "db_remote_state_key" {
  description = "The name of the key in the S3 bucket used for the database's remote state storage"
  type        = string
  default     = "<YOUR STATE PATH>"
}
```

## 1. create_before_destroy 和min_elb_capacity 保证服务不中断


## 2. 修改server_text, 触发ASG 的改变
terraform plan
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place
+/- create replacement and then destroy

Terraform will perform the following actions:

  # module.webserver_cluster.aws_autoscaling_group.example must be replaced
+/- resource "aws_autoscaling_group" "example" {
      ~ name                      = "webservers-stage-terraform-20240130012116682300000001" # forces replacement -> (known after apply) # forces replacement

    }
  # module.webserver_cluster.aws_launch_configuration.example must be replaced
+/- resource "aws_launch_configuration" "example" {
      ~ user_data                        = "26f330707069de910d4745adcc3b050be7381ba6" -> "c3d6a5408985a280333730cecda9c23f576d642f" # forces replacement
    }

Plan: 2 to add, 2 to change, 2 to destroy.
```

## 3. 变更是使用 curl ALB 测试是否中断
```
for i in {1..1000};do curl -I http://webservers-stage-xxxxx.us-east-2.elb.amazonaws.com/;sleep 1;done
```
假如一直有连接上来，targets 的health status有一段时间一直是draining，这个connection draining 默认是300s。排空期间不会接受新链接；但是已建立的连接依然能发送请求。

### 3.1 aws中target group的health status为draining会持续多久？能确保连接都排空了吗？
在 AWS 中，当目标组(Target Group)的健康状态显示为 Draining 时，这意味着目标（例如 EC2 实例）正在被注销，并且负载均衡器正在停止向该目标发送新的请求。Draining 状态通常出现在使用 Elastic Load Balancing (ELB) 的自动缩放过程中，特别是在执行缩容操作时。

持续时间
Draining 状态的持续时间主要由负载均衡器的去注册延迟（Deregistration delay）设置决定。这是一个配置项，用于指定一个目标在完全去注册前，负载均衡器继续向目标发送请求的时间。

去注册延迟：
这个延迟时间可以根据你的应用需要进行设置。它的目的是确保正在进行的请求得以完成，避免在去注册过程中出现连接突然中断的情况。
默认值通常是 300 秒，但你可以根据实际需要进行调整。
确保连接排空
Draining 状态下，负载均衡器确实会等待正在进行的请求完成，但也存在一些注意事项：

新请求：

在 Draining 状态期间，负载均衡器不会向目标发送新的请求。但已经建立的连接（在开始 Draining 之前）可以继续发送请求。
现有连接：

对于现有连接，负载均衡器会等待去注册延迟期间的活动请求完成。在这个时间窗口结束后，即使仍有请求未完成，目标也会被去注册。
长连接：

如果你的应用使用长连接（如 WebSocket），需要特别注意去注册延迟的设置，以确保连接可以优雅关闭。
在使用 Draining 状态和设置去注册延迟时，最好的做法是根据你的应用特性（如请求的平均持续时间、流量模式等）进行调整和测试，确保设置能满足平滑缩容的需求而不会导致服务中断。如果需要，你也可以通过应用程序逻辑来优雅地管理连接关闭。

## 4. 部署

```
terraform init
terraform apply
terraform destroy
```

## 5. 关于变量
- stage的变量优先级高于moudle的优先级。
- db_remote_state_bucket 和 db_remote_state_key 要和mysql 存储状态的位置一样