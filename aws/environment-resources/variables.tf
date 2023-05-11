variable "aws_account" {
  default = "AWS_ACCOUNT_NUMBER"
}
variable "k8s_version" {
  type    = string
  default = "1.19"
}
variable "region" {
  default = "eu-west-1"
}
variable "keys" {
  type = list(string)
}
variable "int_eks_name" {
  description = "The name of the EKS cluster to be deployed in this subnet"
  default     = ""
  type        = string
}
variable "ext_eks_name" {
  description = "The name of the EKS cluster to be deployed in this subnet"
  default     = ""
  type        = string
}

variable "ext_eks_nodegroups" {
  description = "Object containing the EKS nodegroups"
  default     = {}
  type        = map(any)
}

variable "int_eks_nodegroups" {
  description = "Object containing the EKS nodegroups"
  default     = {}
  type        = map(any)
}

variable "int_vpc_cidr" {}
variable "ext_vpc_cidr" {}

variable "r53zone" {
  description = "The route53 zone for the tunnel endpoint"
}
variable "eks_ip_allowlist" {
  type = list(string)
}

variable "ipsec_customer_ip" {
  description = "The IP address for the on-prem end of the tunnel"
}

variable "ipsec_customer_cidrs" {
  description = "The on-prem CIDRS to route to"
  type        = list(string)
}

variable "t1_pskey" {
  description = "The pre-shared key for tunnel 1"
}

variable "t2_pskey" {
  description = "The pre-shared key for tunnel 2"
}

variable "public_subnet_info" {
  description = "Map of subnets to be created"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
}

variable "private_endpoint_subnet_info" {
  description = "Map of subnets to be created"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
}

variable "private_subnet_info" {
  description = "Map of subnets to be created"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
}


variable "ec2_instances" {
  description = "Map of ec2 instances to be created"
  type        = map(any)
  default = {
    public-eu-west-1a = {
      instance_type = "t3a.nano",
      is_public     = true
    },
    private-eu-west-1a = {
      instance_type = "t3a.nano",
      is_public     = false
    },
  }
}

variable "int_nodegroups" {
  type = map(object({
    capacity_type       = string
    instance_type       = string
    max_size            = number
    min_size            = number
    taints              = string
    volumes             = string
    associate_public_ip = bool
    tags                = map(any)
  }))
  default = {}
}

variable "ext_nodegroups" {
  type = map(object({
    capacity_type       = string
    instance_type       = string
    max_size            = number
    min_size            = number
    taints              = string
    volumes             = string
    associate_public_ip = bool
    tags                = map(any)
  }))
  default = {}
}

variable "iam_policies" {
  type = map(any)
  default = {
    "clusterautoscaler" = {
      path        = "/",
      description = "cluster autoscaler",
      policy      = <<EOF
{
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
    }
    "externaldns" = {
      path        = "/",
      description = "external dns",
      policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:GetHostedZone",
        "route53:GetHostedZoneCount",
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    }
  ]
}
EOF
    }

  }
}

variable "int_eks_oidc_iam_roles" {
  type = map(any)
  default = {
    "clusterautoscaler" = {
      "policies" = ["clusterautoscaler"]
    },
    "externaldns" = {
      "policies" = ["externaldns"]
    }
  }
}

variable "ext_eks_oidc_iam_roles" {
  type = map(any)
  default = {
    "clusterautoscaler" = {
      "policies" = ["clusterautoscaler"]
    },
    "externaldns" = {
      "policies" = ["externaldns"]
    }
  }
}

variable "common_eks_nodegroup_sg_egress_cidr_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}

variable "common_eks_nodegroup_sg_ingress_cidr_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}

variable "ext_eks_nodegroup_sg_egress_cidr_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}

variable "ext_eks_nodegroup_sg_ingress_cidr_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}

variable "int_eks_nodegroup_sg_egress_cidr_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}

variable "int_eks_nodegroup_sg_ingress_cidr_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}
