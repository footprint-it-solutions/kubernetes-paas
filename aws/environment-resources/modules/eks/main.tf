resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.iam_role_arn
  version  = var.k8s_version

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  vpc_config {
    endpoint_private_access = true
    subnet_ids              = var.subnet_ids
  }
}

data "tls_certificate" "this" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

locals {
  # Loop through the roles, and then through their policies, adding the arn prefixes
  oidc_iam_roles = {
    for role in keys(var.oidc_iam_roles) :
    role => {
      policies = [
        for policy in var.oidc_iam_roles[role].policies :
        "arn:aws:iam::${var.aws_account}:policy/${policy}"
      ]
    }
  }
}

module "iam_assumable_role_with_oidc" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version  = "~> 4.0"
  for_each = local.oidc_iam_roles

  create_role           = true
  force_detach_policies = true
  provider_url          = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_name             = "${var.eks_cluster_name}-${each.key}"
  role_policy_arns      = each.value.policies

  tags = {
    Role = "${var.eks_cluster_name}-${each.key}"
  }
}

resource "aws_lb" "internal" {
  name               = "${var.eks_cluster_name}-internal"
  internal           = true
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = zipmap(var.subnet_ids, var.subnet_info)

    content {
      subnet_id            = subnet_mapping.key
      private_ipv4_address = replace(subnet_mapping.value["cidr_block"], "/(\\d+\\.\\d+\\.\\d+)\\.\\d+\\/\\d+/", "$1.10")
    }
  }

  enable_deletion_protection = false

  tags = {
    Environment = var.eks_cluster_name
  }
}

resource "aws_lb" "external" {
  count              = var.environment_tier == "ext" ? 1 : 0
  name               = "${var.eks_cluster_name}-internet-facing"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = var.eks_cluster_name
  }
}

resource "aws_lb_listener" "istio_igw_http" {
  load_balancer_arn = var.environment_tier == "int" ? aws_lb.internal.arn : aws_lb.external[0].arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio_igw_http.arn
  }
}

resource "aws_lb_listener" "istio_igw_https" {
  load_balancer_arn = var.environment_tier == "int" ? aws_lb.internal.arn : aws_lb.external[0].arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio_igw_https.arn
  }
}

resource "aws_lb_listener" "istio_ewgw_tls" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "15443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio_ewgw_tls.arn
  }
}

resource "aws_lb_listener" "istio_ewgw_tls_istiod" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "15012"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio_ewgw_tls_istiod.arn
  }
}

resource "aws_lb_listener" "istio_ewgw_tls_webhook" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "15017"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istio_ewgw_tls_webhook.arn
  }
}



resource "aws_lb_target_group" "istio_igw_http" {
  name     = "${var.eks_cluster_name}-istio-igw-http"
  port     = 31080
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/healthz/ready"
    port = 31021
  }
}

resource "aws_lb_target_group" "istio_igw_https" {
  name     = "${var.eks_cluster_name}-istio-igw-https"
  port     = 31443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/healthz/ready"
    port = 31021
  }
}


resource "aws_lb_target_group" "istio_ewgw_tls" {
  name     = "${var.eks_cluster_name}-istio-ewgw-tls"
  port     = 32443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path = "/healthz/ready"
    port = 32021
  }
}

resource "aws_lb_target_group" "istio_ewgw_tls_istiod" {
  name     = "${var.eks_cluster_name}-istio-ewgw-tls-istiod"
  port     = 32012
  protocol = "TCP"
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path = "/healthz/ready"
    port = 32021
  }
}

resource "aws_lb_target_group" "istio_ewgw_tls_webhook" {
  name     = "${var.eks_cluster_name}-istio-ewgw-tls-webhook"
  port     = 32017
  protocol = "TCP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path = "/healthz/ready"
    port = 32021
  }
}



output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
output "ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
output "cluster_security_group_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "nlb_target_groups" {
  value = {
    istio_igw_http = {
      arn = aws_lb_target_group.istio_igw_http.arn
    },
    istio_igw_https = {
      arn = aws_lb_target_group.istio_igw_https.arn
    },
    istio_ewgw_tls = {
      arn = aws_lb_target_group.istio_ewgw_tls.arn
    },
    istio_ewgw_tls_istiod = {
      arn = aws_lb_target_group.istio_ewgw_tls_istiod.arn
    },
    istio_ewgw_tls_webhook = {
      arn = aws_lb_target_group.istio_ewgw_tls_webhook.arn
    }
  }
}
