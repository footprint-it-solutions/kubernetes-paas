variable "aws_account" {}

variable "config" {
  type = map(any)
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
}

variable "iam_role_arn" {
  description = "IAM role arn for node group"
}

variable "name" {}

variable "ssh_keys" {
  default = []
}

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

variable "cluster_security_group_id" {
  description = "the security group id that was created by the cluster"
}

variable "security_group_id" {
  description = "The ID of the nodegroup security group"
}

variable "nlb_target_groups" {
  description = "Load balancer target groups"
}

variable "vpc_id" {
  type = string
}
