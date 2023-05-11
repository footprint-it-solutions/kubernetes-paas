data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

locals {
  nodegroup_roles = [
    {
      rolearn : var.nodegroup_role_arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
}

provider "kubernetes" {
  cluster_ca_certificate = var.api_ca
  host                   = var.api_endpoint
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_config_map" "this" {
  data = {
    mapRoles    = replace(yamlencode(distinct(concat(local.nodegroup_roles, var.additional_iam_roles))), "\"", "")
    mapUsers    = yamlencode(var.additional_iam_users)
    mapAccounts = yamlencode(var.additional_aws_accounts)
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}
