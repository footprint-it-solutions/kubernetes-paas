variable "additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [{
    userarn  = "arn:aws:iam::ACCOUNT_NUMBER:user/USERNAME",
    username = "USERNAME",
    groups   = ["system:masters"]
    }
  ]
}

variable "api_ca" {}
variable "api_endpoint" {}
variable "cluster_name" {}
variable "nodegroup_role_arn" {}

