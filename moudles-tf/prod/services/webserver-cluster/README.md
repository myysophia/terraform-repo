# 知识点
【1】 如何按照时间段进行扩缩容
例如早上九点，需要将ASG 扩容为10台，下午17点之后需要将ASG 缩容为2台，以此来提升资源利用率，节省成本。
aws_autoscaling_schedule
```
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {# (1)  Create a scheduled scaling action to scale out the cluster during business hours
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *" # 每天9点

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" { # (2)  Create a scheduled scaling action to scale in the cluster at night
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *" # 每天五点

  autoscaling_group_name = module.webserver_cluster.asg_name
}
```