resource "aws_launch_template" "this" {
  name = var.name

  dynamic "block_device_mappings" {
    for_each = split(";", var.config.volumes)

    content {
      device_name = element(split(",", block_device_mappings.value), 0)
      ebs {
        volume_size           = element(split(",", block_device_mappings.value), 1)
        volume_type           = element(split(",", block_device_mappings.value), 2)
        delete_on_termination = true
        # encrypted = true
        # kms_key_id = aws_kms_key.ebs_key.arn
      }
    }
  }

  network_interfaces {
    associate_public_ip_address = var.config.associate_public_ip
    delete_on_termination       = true
    device_index                = 0
    security_groups             = [var.cluster_security_group_id, var.security_group_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.name
    }
  }

  user_data = base64encode(
    templatefile("${path.module}/user_data.sh", {
      keys = var.ssh_keys
    })
  )
}

resource "aws_eks_node_group" "this" {
  count = length(var.subnet_info)

  ami_type       = can(var.config.ami_type) ? var.config.ami_type : "AL2_x86_64"
  capacity_type  = var.config.capacity_type
  cluster_name   = var.eks_cluster_name
  instance_types = split(",", replace(var.config.instance_types, " ", ""))

  lifecycle {
    ignore_changes = [
      scaling_config["desired_size"]
    ]
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  node_group_name = "${var.name}-${count.index}"
  node_role_arn   = var.iam_role_arn

  scaling_config {
    desired_size = var.config.desired_size
    max_size     = var.config.max_size
    min_size     = var.config.min_size
  }

  subnet_ids = [element(var.subnet_ids, count.index)]

  dynamic "taint" {
    for_each = var.config.taints != "" ? split(";", var.config.taints) : []
    content {
      effect = element(split(",", taint.value), 0)
      key    = element(split(",", taint.value), 1)
      value  = element(split(",", taint.value), 2)
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "15m"
  }
}

module "asg_tags" {
  source = "./asg_tags"
  count  = length(var.subnet_info)

  asg_name          = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name
  node_group_taints = aws_eks_node_group.this[count.index].taint
}

resource "aws_autoscaling_attachment" "istio_igw_http" {
  count = length(var.subnet_info)

  alb_target_group_arn   = var.nlb_target_groups.istio_igw_http.arn
  autoscaling_group_name = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_attachment" "istio_igw_https" {
  count = length(var.subnet_info)

  alb_target_group_arn   = var.nlb_target_groups.istio_igw_https.arn
  autoscaling_group_name = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_attachment" "istio_ewgw_tls" {
  count = length(var.subnet_info)

  alb_target_group_arn   = var.nlb_target_groups.istio_ewgw_tls.arn
  autoscaling_group_name = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_attachment" "istio_ewgw_tls_istiod" {
  count = length(var.subnet_info)

  alb_target_group_arn   = var.nlb_target_groups.istio_ewgw_tls_istiod.arn
  autoscaling_group_name = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_attachment" "istio_ewgw_tls_webhook" {
  count = length(var.subnet_info)

  alb_target_group_arn   = var.nlb_target_groups.istio_ewgw_tls_webhook.arn
  autoscaling_group_name = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name
}
