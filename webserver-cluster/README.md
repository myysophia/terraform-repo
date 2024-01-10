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
# 问题
<<<<<<< HEAD
【1】dns 解析记录无法更新
ALB 的后端health check 端口不对，导致LB 后端一直没有健康的节点，更正health check规则后，重新拉起了两台ec2，
dig dns 一直看到的是旧的IP，无法更新。
=======

# 架构
![image](https://github.com/myysophia/terraform-repo/assets/25994521/9d0866ae-a81b-4b7b-a6bf-ee7fd1f81c45)

>>>>>>> 26c8133920b4f2e20d93094992b803016878f84c
