# 背景
接触到aws，这里记录一些terraform的脚手架代码。
terraform 可以将基础架构用代码的方式进行表示，也就是IaC的概念，基础设施即代码。
可以将terraform代码库用git 进行管理，进行版本管控,共享给其他人；避免在控制台手动创建，手动创建耗时、且依靠人的记忆、易出错。
因为aws的平台是一致的，只需要配置自己的凭证就可以快速构建基础设施。
# EKS
aws k8s解决方案。
- main.tf 中定义了主要逻辑，包括创建eks的各种资源例如provider 、 各种moudle(vpc/subnet/eip/igw/nat gw/eks/addons), 以及一些变量。
providers 中的profile 和aws 的config一致，会自动读取~/.aws/credentials对应的AK/SK。
```
provider "aws" {
  region = var.region
  profile = "tf-test"
}

# ~/.aws/config
[default]
region = us-east-1
[tf-test]
region = us-east-2

# ~/.aws/credentials
[default]
aws_access_key_id = XXXX
aws_secret_access_key = xxxx
[tf-test]
aws_access_key_id = XXXX
aws_secret_access_key = xxxx

```
  
- terraform.tf 中定义的使用的hashicorp插件， 执行terraform init的就是在下载这些插件
- variable.tf 定义了公用变量，根据实际情况抽取
- output.tf 定义了apply时输出的格式
- tfplan 是terraform plan生成的计划，用于确认集群的配置是否正确
- log目录中是执行的日志
## 使用说明
【0】 tips
1. 关于输入变量，如果变量没有default值，则会在执行apply时提示你输入变量的值。
   variable "ami" {
      default = "ami-0ac73f33a1888c64a"
   }
   或者可以使用terraform apply -var 'ami=123123' 覆盖变量的默认值。
   或者可以使用环境变量进行导出，export TF_VAR_ami="123231".  unset TF_VAR_ami 快速取消这个变量
   或者创建一个terraform.tfvars 将变量填入，ami="123123"
2. 输出变量
   ```
     #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
#Resource: aws_eip
resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.server.id
}
#output.tf 
output "ip" {
  value = aws_eip.ip.public_ip
}

terraform apply 会输出展示EIP。

3. 团队协作使用terraform创建资源，tfstate需要使用S3 + dynamicDB作为后端管理状态，[参考]([url](https://github.com/antonputra/tutorials/blob/main/lessons/040/provider.tf))
需要有[S3 + dynamicDB]([url](https://developer.hashicorp.com/terraform/language/settings/backends/s3))的权限(https://developer.hashicorp.com/terraform/language/settings/backends/s3)。


5. 生成kubeconfig
确保在 ~/.aws/credentials 和 ~/.aws/config 文件中正确配置了 profile，包括它的名称、访问密钥、秘密密钥和可选的默认区域。
aws eks update-kubeconfig --region <region-code> --name <cluster-name>
aws eks update-kubeconfig --region ap-southeast-2 --name nova-eks-terraform

【1】 配置好aws 凭证
**注意生成凭证时选择正确的类型**
![image](https://github.com/myysophia/terraform-repo/assets/25994521/c042138e-a8e0-4b34-98a9-f87591d5855c)

【2】 部署eks

- terraform init  下载provider的代码以及插件
- terraform validate  校验语法
- terraform plan -out tfplan  生成计划，需要确认下创建与删除的资源。类似于k8s的 --dry-run
- terraform apply ./eks  实际执行，也会执行plan 再次让你确认才会真正创建资源
- terraform destroy 删除eks 所有资源。[参考]([url](https://gist.github.com/myysophia/65ee79af5d42b8e7c3266f8a88dfcf49))

【3】 查看集群
k get node

【4】参考
1. [操作指南](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)
2. [项目地址](https://github.com/hashicorp/learn-terraform-provision-eks-cluster/tree/main)

[3. **How to Create EKS Cluster Using Terraform?](https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/)** 

[How to Create EKS Cluster Using Terraform? github repo](https://github.com/antonputra/tutorials/tree/main/lessons/102)
