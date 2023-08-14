provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


data "aws_eks_cluster_auth" "config" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.config.token
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.0"
    }
  }
}
