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
