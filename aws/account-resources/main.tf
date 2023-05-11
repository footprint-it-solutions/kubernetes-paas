terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

module "kms" {
  source = "./modules/kms"
}

module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source   = "./modules/ecr"
  for_each = toset(local.container_images)

  name        = each.key
  aws_account = data.aws_caller_identity.current.account_id
}

output "all" {
  value = {
    iam = module.iam
  }
}
