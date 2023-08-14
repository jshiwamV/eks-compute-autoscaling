variable "region" {
  description = "AWS Region in which the terraform resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "Virtual Network CIDR Block"
  type        = string
  default = "10.0.0.0/16"
}

variable "access_key" {
  description = "AWS Account Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS account Secret Key"
  type        = string
}
