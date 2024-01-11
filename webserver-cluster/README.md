# 知识点
【1】资源创建与销毁的顺序，如何保证最小的停机时间以及做到平滑迁移。
```
resource "aws_instance" "example" {
  lifecycle {
    create_before_destroy = true
  }
}
```
create_before_destroy = true，Terraform 会先创建新资源，确保新资源完全启动并运行后，再销毁旧资源。 和k8s中deployment的rollingupdate 逻辑类似。

【2】aws_autoscaling_group 和resource "aws_launch_configuration" "example" 的使用场景
定义一个 aws_launch_configuration 来指定 EC2 实例的配置。然后，创建一个 aws_autoscaling_group 并引用这个配置，以决定如何根据负载或计划来动态调整这些实例的数量。
aws_autoscaling_group 利用 aws_launch_configuration 来管理一组 EC2 实例的扩展和管理。它定义了如何扩展（比如根据何种指标、最小/最大实例数量等），以及实例的分布（如在哪些可用区中部署实例）。
使用场景：
动态扩展和收缩：根据负载（如 CPU 使用率、网络流量或自定义指标）自动增加或减少实例数量。
容错和高可用性：通过在多个可用区中分布实例来确保应用的高可用性。
负载均衡：与 AWS 负载均衡器结合使用，以分配流量到多个实例。

【3】ALB如何挂载后端服务？aws_lb、aws_lb_listener、aws_lb_target_group 和aws_lb_listener_rule的作用与联系？
 在 AWS 中，使用 Terraform 配置负载均衡器涉及到多个组件：aws_lb（负载均衡器本身）、aws_lb_listener（监听器）、aws_lb_target_group（目标组）以及 aws_lb_listener_rule（监听器规则）。这些组件共同工作，提供了一个强大而灵活的方式来分发入站流量到后端服务器或服务。

负载均衡器 (aws_lb) 接收所有入站流量。
监听器 (aws_lb_listener) 附加到负载均衡器上，监听特定的端口和协议。
监听器规则 (aws_lb_listener_rule) 决定根据特定条件（如 URL 路径）将流量转发到哪个目标组。
目标组 (aws_lb_target_group) 接收符合规则的流量，并将其分发到其下的目标（如 EC2 实例）。

【4】aws_lb_listener_rule 的action type中forward和redirect使用场景是什么？
AWS 的 aws_lb_listener_rule 资源中，action 定义了负载均衡器在匹配到特定规则时应采取的操作。其中，forward 和 redirect 是两种常用的操作类型，它们在不同的场景中发挥作用。

Forward（转发）
作用：forward 动作用于将流量转发到一个或多个目标组。它是最常见的动作类型，用于常规的负载均衡。
使用场景：
应用流量分发：将入站流量基于特定条件（如请求路径或主机头）分发到不同的后端服务器或服务。例如，将对 /api 的请求转发到 API 服务器的目标组，而将其他请求转发到静态内容的目标组。
微服务架构：在微服务架构中，根据服务的路径或其他标识符将流量转发到相应的服务。

Redirect（重定向）
作用：redirect 动作用于重定向客户端到一个不同的 URL。这可以包括更改协议（如从 HTTP 到 HTTPS）、主机名、路径或查询字符串。
使用场景：
HTTP 到 HTTPS：自动将 HTTP 请求重定向到 HTTPS，以提高安全性。例如，当用户访问 http://example.com 时，将其重定向到 https://example.com。
URL 重写：更改请求的路径或查询参数。例如，基于旧网站的 URL 结构重定向到新网站的 URL。
维护或暂时重定向：在网站维护或临时性事件期间，将流量重定向到其他页面或网站。

```
resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.example.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_listener_rule" "redirect" {
  listener_arn = aws_lb_listener.example.arn

  action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"
    }
  }

.
}

```


# 问题

【1】dns 解析记录无法更新
ALB 的后端health check 端口不对，导致LB 后端一直没有健康的节点，更正health check规则后，重新拉起了两台ec2，
dig dns 一直看到的是旧的IP，无法更新。


# 架构
![image](https://github.com/myysophia/terraform-repo/assets/25994521/9d0866ae-a81b-4b7b-a6bf-ee7fd1f81c45)

