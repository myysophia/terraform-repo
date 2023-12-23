# 背景
接触到aws，这里记录一些terraform的脚本
# EKS
aws k8s解决方案。
- main.tf 中定义了主要逻辑，包括创建eks的各种资源例如provider 、 各种moudle(vpc/subnet/eip/igw/nat gw/eks/addons), 以及一些变量
- terraform.tf 中定义的使用的hashicorp插件， 执行terraform init的就是在下载这些插件
- variable.tf 定义了公用变量，根据实际情况抽取
- output.tf 定义了apply时输出的格式
- tfplan 是terraform plan生成的计划，用于确认集群的配置是否正确
- log目录中是执行的日志
## 使用说明
【1】 配置好aws 凭证
注意生成凭证时选择正确的类型
![image](https://github.com/myysophia/terraform-repo/assets/25994521/c042138e-a8e0-4b34-98a9-f87591d5855c)

【2】 部署eks

- terraform init
- terraform validate
- terraform plan -out tfplan
- terraform apply ./eks

【3】 查看集群
k get node

【4】参考
1. [操作指南](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)
2. [项目地址](https://github.com/hashicorp/learn-terraform-provision-eks-cluster/tree/main)

[3. **How to Create EKS Cluster Using Terraform?](https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/)** 

[How to Create EKS Cluster Using Terraform? github repo](https://github.com/antonputra/tutorials/tree/main/lessons/102)
