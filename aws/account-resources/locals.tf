locals {
  container_images = [
    "amazon-k8s-cni",
    "autoscaling/cluster-autoscaler",
    "bitnami/alertmanager",
    "bitnami/external-dns",
    "bitnami/kube-state-metrics",
    "bitnami/node-exporter",
    "bitnami/prometheus-operator",
    "bitnami/prometheus",
    "curlimages/curl",
    "eks/coredns",
    "eks/kube-proxy",
    "environment-mgmt/k8s-auditor",
    "fmlabs/alpine-helm",
    "grafana/grafana",
    "haproxytech/haproxy-alpine",
    "istio-release/pilot",
    "istio-release/proxyv2",
    "istio/examples-helloworld-v1",
    "jetstack/cert-manager-cainjector",
    "jetstack/cert-manager-controller",
    "jetstack/cert-manager-webhook",
    "kiali/kiali",
    "kyverno/kyverno"
  ]
}
