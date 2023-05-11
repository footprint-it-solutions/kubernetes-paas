variable "aws_account" {}

variable "eks_cluster_name" {
  description = "EKS cluster name"
}

variable "k8s_version" {
  type = string
}

variable "eks_ip_allowlist" {
  type = list(string)
}

variable "environment_tier" {}

variable "region" {}

variable "service_ipv4_cidr" {}

variable "subnet_ids" {
  description = "EKS cluster subnets"
  type        = list(string)
}

variable "subnet_info" {
  description = "Map of subnets to be created"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
}

variable "iam_role_arn" {
  description = "IAM cluster role arn for EKS"
}

variable "oidc_iam_roles" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}
