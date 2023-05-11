# cluster role and attachments
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "EKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}


# nodegroup role and attachments
resource "aws_iam_role" "eks_nodegroup_role" {
  for_each = toset(["int-eks", "ext-eks"])

  name = "${each.key}-nodegroup-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "EKSWorkerNodePolicy" {
  for_each = toset(["int-eks", "ext-eks"])

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
  for_each = toset(["int-eks", "ext-eks"])

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role[each.key].name
}

resource "aws_iam_role_policy_attachment" "EC2ContainerRegistryReadOnly" {
  for_each = toset(["int-eks", "ext-eks"])

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role[each.key].name
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "ext_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["ext-eks"].arn
}

output "int_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["int-eks"].arn
}
