
  # 原生零宕机(Use instance refresh to roll out changes to the ASG)

```
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
```