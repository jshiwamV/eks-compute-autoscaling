variable "region" {
    type = string
    description = "region where the EKS cluster exists"
}

variable "cluster_name" {
  type        = string
  description = "name of the eks cluster"
}

variable "cluster_endpoint" {
  type        = string
  description = "name of the cluster endpoint"
}

variable "cluster_certificate_authority_data" {
  type        = string
  description = "eks cluster certificate authority"
}

variable "cluster_autoscaler_irsa_name" {
    type = string
    description = "IAM role name for cluster autoscaler irsa"
}

variable "cluster_autoscaler_irsa_arn" {
    type = string
    description = "IAM role arn for cluster autoscaler irsa"
}
