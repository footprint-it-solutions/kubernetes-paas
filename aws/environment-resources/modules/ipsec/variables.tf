variable "vpc_id" {
  description = "The VPC id where this tunnel is created from"
}

variable "customer_ip" {
  description = "The IP on the customer side of the tunnel"
}

variable "customer_cidrs" {
  description = "The on-prem CIDRS to route to"
  type        = list(string)
}

variable "t1_pskey" {
  description = "The preshared key of the first VPN tunnel."
}

variable "t2_pskey" {
  description = "The preshared key of the second VPN tunnel."
}

variable "region" {
  description = "The region of this vpn tunnel"
}

variable "r53zone_id" {
  description = "The route53 zone id"
}

variable "r53zone_name" {
  description = "The route53 zone name"
}

variable "private_route_table_id" {
  description = "The route table id for the private subnets"
}
