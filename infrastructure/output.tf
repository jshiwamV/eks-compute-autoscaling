output "region" {
  value = var.region
}

output "karpenter_role_arn" {	
  value = module.karpenter.role_arn	
}
	
output "karpenter_instance_profile_name" {	
  value = module.karpenter.instance_profile_name	
}	

output "karpenter_irsa_arn" {
  value = module.karpenter.irsa_arn
}

output "cluster_autoscaler_irsa_arn" {
  value = module.cluster_autoscaler.iam_role_arn
}

output "cluster_autoscaler_irsa_name" {
    value = module.cluster_autoscaler.iam_role_name
}

output "cluster_name" {
    value = module.eks.cluster_name
}

output "eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
    value = module.eks.cluster_certificate_authority_data
    sensitive = true
}

output "cluster_token" {
    value = data.aws_eks_cluster_auth.config.token
    sensitive = true
}
