terraform {
  required_providers {
    helm = {
      configuration_aliases = [helm.cluster]
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  provider = helm.cluster
  name     = "cluster-autoscaler"

  chart = "cluster-autoscaler"

  lint       = true
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"

  values = [
    templatefile("${path.module}/helm/values.yaml", {
      cluster_name           = var.cluster_name
      custom_docker_registry = var.custom_docker_registry
      region                 = var.region
    })
  ]
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${var.aws_account}:role/${var.cluster_name}-clusterautoscaler"
  }
}
