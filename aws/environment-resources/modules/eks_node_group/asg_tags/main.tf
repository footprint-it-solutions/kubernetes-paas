data "aws_autoscaling_group" "this" {
  name = var.asg_name
}

data "aws_arn" "this" {
  arn = data.aws_autoscaling_group.this.arn
}

resource "null_resource" "taints" {
  provisioner "local-exec" {
    command = <<EOF
      aws autoscaling create-or-update-tags --region ${data.aws_arn.this.region} --tags '${jsonencode([for taint in var.node_group_taints : {
    "ResourceId" : var.asg_name
    "ResourceType" : "auto-scaling-group",
    "Key" : "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}",
    "Value" : "${taint.value}:${taint.effect == "NO_EXECUTE" ? "NoExecute" : "NoSchedule"}",
    "PropagateAtLaunch" : true
}])}'
    EOF
}

triggers = {
  "asg"    = data.aws_autoscaling_group.this.arn
  "taints" = jsonencode(var.node_group_taints)
}
}
