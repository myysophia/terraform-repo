# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
  profile = "nova-tf-test"
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "nova-eks-terraform"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # 可基于开源的moudle自定义适配业务的moudle
  version = "5.0.0"

  name = "terrform-nova-test-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3) # 选择可用区（AZs）。这里它从 AWS 的可用区数据源中选择前三个可用区。这是因为我们将在这些可用区中部署我们的 EKS 集群和节点组。

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true # 为了让节点组能够访问互联网，我们需要启用 NAT 网关。这个模块会自动创建 NAT 网关，并将它们与私有子网相关联。
  single_nat_gateway   = true # 为了简单起见，我们只创建一个 NAT 网关。这意味着所有的私有子网都将使用同一个 NAT 网关。
  enable_dns_hostnames = true 

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared" # 为了让 EKS 集群能够识别出哪些子网是公共子网，我们需要为它们添加一个特殊的标签。这个标签的键是 kubernetes.io/cluster/${local.cluster_name}，值是 shared。
    "kubernetes.io/role/elb"                      = 1 # 公共负载均衡器
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1 # 内部负载均衡器
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
#  用于获取和使用由其他人或服务创建的数据。它们在 Terraform 配置中允许你引用不是由当前配置管理的资源。
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
# 这个模块配置了一个 IAM 角色，允许特定的 Kubernetes 服务账户通过 EKS 集群的 OIDC 提供者进行身份验证，并赋予了它访问 AWS 资源的权限（具体是 EBS CSI 相关的权限）
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}
