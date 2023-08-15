variable "replica_count" {
  type        = string
  default     = "5"
  description = "number of replicas for the deployment"
}

variable "region" {
  type        = string
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

variable "karpenter_instance_profile_name" {
  type        = string
  description = "karpenter instance profile name"
}

variable "karpenter_irsa_arn" {
  type        = string
  description = "karpenter IRSA  arn"
}

variable "karpenter_role_arn" {
  type        = string
  description = "karpenter role arn"
}

variable "eks_managed_node_group_id" {
  type        = string
  description = "eks managed node group id"
}
