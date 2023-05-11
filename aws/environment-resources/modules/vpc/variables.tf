variable "region" {
  default = "eu-west-1"
}

variable "int_cidr_block" {
  type        = string
  description = "CIDR for the int VPC"
}

variable "ext_cidr_block" {
  type        = string
  description = "CIDR for the ext VPC"
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC"
  default     = true
}

variable "ingress_rules" {
  description = "ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "allow SSH in"
    from_port   = 22,
    to_port     = 22,
    protocol    = "tcp",
    cidr_blocks = ["10.10.0.0/16"]
    },
    {
      description = "allow ICMP ping in"
      from_port   = -1,
      to_port     = -1,
      protocol    = "icmp",
      cidr_blocks = ["10.10.0.0/16"]
    },
    {
      description = "allow https in"
      from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
      cidr_blocks = ["10.10.0.0/16"]
    },
  ]
}

variable "egress_rules" {
  description = "egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "allow all out"
    from_port   = 0,
    to_port     = 0,
    protocol    = "all",
    cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "allow ICMP ping out"
      from_port   = -1,
      to_port     = -1,
      protocol    = "icmp",
      cidr_blocks = ["0.0.0.0/0"]
  }]
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

variable "int_vpc_cidr" {}
variable "ext_vpc_cidr" {}

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
