# variable "private_subnet_ids" {
#   description = "Map of subnet ids"
#   type        = list(string)
# }

variable "eks_cluster_name" {
  description = "EKS cluster name"
}

variable "subnets" {
  description = "Map of subnets"
  type = map(object({
    availability_zone = string
    cidr_block        = string
    id                = string
  }))
}

variable "security_group_id" {
  description = "ID of the security group for EFS"
  type        = string
}
