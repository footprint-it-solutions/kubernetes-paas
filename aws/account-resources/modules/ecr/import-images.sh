#!/bin/bash

# IMAGES=$(kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
# tr -s '[[:space:]]' '\n' |\
# sort |\
# uniq)

IMAGES='
602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon-k8s-cni:v1.7.5-eksbuild.1
602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/coredns:v1.8.0-eksbuild.1
602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/kube-proxy:v1.19.6-eksbuild.2
curlimages/curl
docker.io/bitnami/alertmanager:0.22.1-debian-10-r5
docker.io/bitnami/external-dns:0.8.0-debian-10-r26
docker.io/bitnami/kube-state-metrics:2.0.0-debian-10-r28
docker.io/bitnami/node-exporter:1.1.2-debian-10-r64
docker.io/bitnami/prometheus:2.27.1-debian-10-r13
docker.io/bitnami/prometheus-operator:0.48.1-debian-10-r0
docker.io/istio/examples-helloworld-v1
gcr.io/istio-release/pilot:1.10.0
gcr.io/istio-release/proxyv2:1.10.0
ghcr.io/kyverno/kyverno:v1.3.6
grafana/grafana:8.0.1
haproxytech/haproxy-alpine:2.4.0
k8s.gcr.io/autoscaling/cluster-autoscaler:v1.20.0
quay.io/jetstack/cert-manager-cainjector:v1.3.1
quay.io/jetstack/cert-manager-controller:v1.3.1
quay.io/jetstack/cert-manager-webhook:v1.3.1
quay.io/kiali/kiali:v1.35.0
'

while read -r image; do
  if [[ ! -z $image ]]; then
    echo $image

    # Docker pull the image
    docker pull $image

    # Check the first segment of the line
    SUB='.'
    REGISTRY='AWS_ACCOUNT_NUMBER.dkr.ecr.eu-west-1.amazonaws.com'

    FIRST_SEQ=$(echo $image | awk -F / '{print $1}')
    NEW_IMG=""
    if [[ "$FIRST_SEQ" == *"$SUB"* ]]; then
      NEW_IMG=$(echo $image | sed -e "s/$FIRST_SEQ/$REGISTRY/g" )
    else
      NEW_IMG="$REGISTRY/$image"
    fi
    echo $NEW_IMG
    docker tag $image $NEW_IMG

    docker push $NEW_IMG
  fi
done <<< $IMAGES
