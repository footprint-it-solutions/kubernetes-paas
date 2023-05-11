# kubernetes-paas

Multi-cloud Kubernetes Platform as a Service

## setup this stack is supposed to be applied in this order

1. account-bootstrap
    - setting up terraform remote backend with s3+dynamodb

2. account-resources
    - ECR/GCR
    - KMS
    - IAM

3. environment-resources
    - VPC (igw, secgrp)
    - public subnet per az (routes + internet via IGW)
    - private subnet per az (routes + internet via VPG ipsec-on-prem)
    - EKS iam, eks cluster, eks nodegroups
    - IPsec tunnel

4. k8s-resources
    - istio mesh
    - external dns
    - cert-manager
    - kiali
    - grafana
    - prometheus operator



## Spikes

- tags module for consistent tagging of all resources
- environment variation (team-variation-tier)
    - team: the team owning this resource (is this needed ?)
    - variation: blue/green variation of this resource
    - tier: dev, stage, prod levels of this resource
