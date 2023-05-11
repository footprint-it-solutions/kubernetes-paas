data "aws_kms_key" "eks" {
  key_id = "alias/eks"
}

resource "aws_efs_file_system" "eks" {
  creation_token = "eks-paas"
  encrypted      = true
  kms_key_id     = data.aws_kms_key.eks.arn

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "eks-paas"
  }
}

resource "aws_efs_mount_target" "eks" {
  for_each        = var.subnets
  file_system_id  = aws_efs_file_system.eks.id
  subnet_id       = each.value.id
  security_groups = [var.security_group_id]
}
