terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.46.0"
    }
  }
}
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source         = "./modules/vpc"
  int_cidr_block = var.int_vpc_cidr
  ext_cidr_block = var.ext_vpc_cidr
  region         = var.region

  int_eks_name = var.int_eks_name
  ext_eks_name = var.ext_eks_name

  public_subnet_info           = var.public_subnet_info
  private_endpoint_subnet_info = var.private_endpoint_subnet_info
  private_subnet_info          = var.private_subnet_info

  int_vpc_cidr = var.int_vpc_cidr
  ext_vpc_cidr = var.ext_vpc_cidr
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] #canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_route53_zone" "this" {
  name         = var.r53zone
  private_zone = false
}

module "ipsec_tunnel" {
  source                 = "./modules/ipsec"
  vpc_id                 = module.vpc.int_vpc_id
  region                 = var.region
  customer_ip            = var.ipsec_customer_ip
  customer_cidrs         = var.ipsec_customer_cidrs
  t1_pskey               = var.t1_pskey
  t2_pskey               = var.t2_pskey
  r53zone_id             = data.aws_route53_zone.this.id
  r53zone_name           = data.aws_route53_zone.this.name
  private_route_table_id = module.vpc.route_tables.private_route_table_id
}

module "iam_policies" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version  = "~> 3.0"
  for_each = var.iam_policies

  name        = each.key
  path        = each.value.path
  description = each.value.description
  policy      = each.value.policy
}

module "int_eks" {
  source = "./modules/eks"

  depends_on = [
    module.iam_policies
  ]

  environment_tier = "int"
  region           = var.region
  aws_account      = data.aws_caller_identity.current.account_id
  eks_cluster_name = var.int_eks_name
  k8s_version      = var.k8s_version

  eks_ip_allowlist = var.eks_ip_allowlist
  subnet_ids       = module.vpc.subnet_ids.private_subnet_ids
  subnet_info      = var.private_subnet_info
  vpc_id           = module.vpc.int_vpc_id

  iam_role_arn      = data.terraform_remote_state.account_resources.outputs.all.iam.eks_cluster_role_arn
  oidc_iam_roles    = var.int_eks_oidc_iam_roles
  service_ipv4_cidr = "172.20.0.0/16"
}

module "int_eks_aws_auth" {
  source = "./modules/eks_aws_auth"

  api_ca             = base64decode(module.int_eks.ca)
  api_endpoint       = module.int_eks.endpoint
  cluster_name       = var.int_eks_name
  nodegroup_role_arn = data.terraform_remote_state.account_resources.outputs.all.iam.int_eks_nodegroup_role_arn
}

module "int_eks_nodegroup_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  description = "Security group for EKS node groups"
  name        = "${var.int_eks_name}-nodegroup"

  egress_with_cidr_blocks = concat(
    var.common_eks_nodegroup_sg_egress_cidr_rules,
    var.int_eks_nodegroup_sg_egress_cidr_rules
  )

  ingress_with_cidr_blocks = concat(
    var.common_eks_nodegroup_sg_ingress_cidr_rules,
    var.int_eks_nodegroup_sg_ingress_cidr_rules
  )

  vpc_id = module.vpc.int_vpc_id
}

module "int_eks_nodegroups" {
  for_each = var.int_eks_nodegroups
  source   = "./modules/eks_nodegroup"

  aws_account               = data.aws_caller_identity.current.account_id
  cluster_security_group_id = module.int_eks.cluster_security_group_id
  config                    = each.value
  eks_cluster_name          = var.int_eks_name
  iam_role_arn              = data.terraform_remote_state.account_resources.outputs.all.iam.int_eks_nodegroup_role_arn
  name                      = "${var.int_eks_name}-ng-${each.key}"
  nlb_target_groups         = module.int_eks.nlb_target_groups
  security_group_id         = module.int_eks_nodegroup_security_group.security_group_id
  subnet_ids                = module.vpc.subnet_ids.private_subnet_ids
  subnet_info               = var.private_subnet_info
  vpc_id                    = module.vpc.int_vpc_id

  depends_on = [
    module.int_eks_aws_auth,
    module.ipsec_tunnel
  ]
}


module "ext_eks" {
  source = "./modules/eks"

  depends_on = [
    module.iam_policies
  ]

  environment_tier = "ext"
  region           = var.region
  aws_account      = data.aws_caller_identity.current.account_id
  eks_cluster_name = var.ext_eks_name
  k8s_version      = var.k8s_version

  eks_ip_allowlist = var.eks_ip_allowlist
  subnet_ids       = module.vpc.subnet_ids.public_subnet_ids
  subnet_info      = var.public_subnet_info
  vpc_id           = module.vpc.ext_vpc_id

  iam_role_arn      = data.terraform_remote_state.account_resources.outputs.all.iam.eks_cluster_role_arn
  oidc_iam_roles    = var.ext_eks_oidc_iam_roles
  service_ipv4_cidr = "172.21.0.0/16"
}

module "ext_eks_aws_auth" {
  source = "./modules/eks_aws_auth"

  api_ca             = base64decode(module.ext_eks.ca)
  api_endpoint       = module.ext_eks.endpoint
  cluster_name       = var.ext_eks_name
  nodegroup_role_arn = data.terraform_remote_state.account_resources.outputs.all.iam.ext_eks_nodegroup_role_arn
}

module "ext_eks_nodegroup_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  description = "Security group for EKS node groups"
  name        = "${var.ext_eks_name}-nodegroup"

  egress_with_cidr_blocks = concat(
    var.common_eks_nodegroup_sg_egress_cidr_rules,
    var.ext_eks_nodegroup_sg_egress_cidr_rules
  )

  ingress_with_cidr_blocks = concat(
    var.common_eks_nodegroup_sg_ingress_cidr_rules,
    var.ext_eks_nodegroup_sg_ingress_cidr_rules
  )

  vpc_id = module.vpc.ext_vpc_id
}

module "ext_eks_nodegroups" {
  for_each = var.ext_eks_nodegroups
  source   = "./modules/eks_nodegroup"

  aws_account               = data.aws_caller_identity.current.account_id
  eks_cluster_name          = var.ext_eks_name
  cluster_security_group_id = module.ext_eks.cluster_security_group_id
  config                    = each.value
  iam_role_arn              = data.terraform_remote_state.account_resources.outputs.all.iam.ext_eks_nodegroup_role_arn
  name                      = "${var.ext_eks_name}-ng-${each.key}"
  nlb_target_groups         = module.ext_eks.nlb_target_groups
  security_group_id         = module.ext_eks_nodegroup_security_group.security_group_id
  subnet_ids                = module.vpc.subnet_ids.public_subnet_ids
  subnet_info               = var.public_subnet_info
  vpc_id                    = module.vpc.ext_vpc_id

  depends_on = [
    module.ext_eks_aws_auth
  ]
}

output "all_outputs" {
  value = {
    vpc     = module.vpc
    ipsec   = module.ipsec_tunnel
    int_eks = module.int_eks
    ext_eks = module.ext_eks
  }
}
