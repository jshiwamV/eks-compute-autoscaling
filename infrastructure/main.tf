locals {
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]

  az_count = length(local.azs)
  name     = "autoscaler-demo"
  tags = {
    Demo    = "autoscalers"
    Kapstan = true
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]


  private_subnet_suffix = "private-subnet"
  public_subnet_suffix  = "public-subnet"
  intra_subnet_suffix   = "intra-subnet"

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
  }

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = local.name
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version = "v1.9.3-eksbuild.3"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version = "v1.24.10-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.12.6-eksbuild.1"
    }
  }

  vpc_id                                     = module.vpc.vpc_id
  subnet_ids                                 = module.vpc.private_subnets
  control_plane_subnet_ids                   = module.vpc.intra_subnets
   
   # aws-auth configmap
   manage_aws_auth_configmap = true
  
   aws_auth_roles = [
     {
      rolearn  = module.eks_managed_node_group.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:nodes", "system:bootstrappers"]
     },
     {
      rolearn = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = ["system:nodes", "system:bootstrappers"]
     },
   ]

  create_cluster_primary_security_group_tags = true

  cluster_security_group_tags = {
    "karpenter.sh/discovery" = local.name
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${local.name}" = null
    "karpenter.sh/discovery"              = local.name
  }


  tags = local.tags
}

module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "19.13.1"
  force_update_version = true

  name            = local.name
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  network_interfaces = [
        {
          description                 = "${local.name}-eni"
          delete_on_termination       = true
        }
  ]

  subnet_ids = module.vpc.private_subnets

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids = [
    module.eks.node_security_group_id,
  ]

  min_size     = 1
  max_size     = 8
  desired_size = 1

  instance_types = ["t3.large"]

  ami_type = "AL2_x86_64"

  capacity_type = "SPOT"

  disk_size = 50

  tags = local.tags
}

# IRSA for Karpenter
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.13.1"

  cluster_name = local.name

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["kube-system:karpenter"]

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

# IRSA for cluster autoscaler
module "cluster_autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.5.7"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = local.tags
}
