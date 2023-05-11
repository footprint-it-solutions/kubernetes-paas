int_eks_name = "int-eks"
ext_eks_name = "ext-eks"

int_vpc_cidr = "10.10.0.0/22"
ext_vpc_cidr = "10.10.4.0/22"

eks_ip_allowlist = []
ipsec_customer_ip    = "1.2.3.4"
ipsec_customer_cidrs = ["10.10.0.0/24"]

private_endpoint_subnet_info = [
  {
    cidr_block        = "100.64.10.0/26",
    availability_zone = "eu-west-1a",
    type              = "private"
  },
  {
    cidr_block        = "100.64.10.64/26",
    availability_zone = "eu-west-1b",
    type              = "private"
  },
  {
    cidr_block        = "100.64.10.128/26",
    availability_zone = "eu-west-1c",
    type              = "private"
  }
]

private_subnet_info = [
  {
    cidr_block        = "10.10.0.0/24",
    availability_zone = "eu-west-1a",
    type              = "private"
  },
  {
    cidr_block        = "10.10.1.0/24",
    availability_zone = "eu-west-1b",
    type              = "private"
  },
  {
    cidr_block        = "10.10.2.0/24",
    availability_zone = "eu-west-1c",
    type              = "private"
  }
]

public_subnet_info = [
  {
    cidr_block        = "10.10.3.0/26",
    availability_zone = "eu-west-1a",
    type              = "public"
  },
  {
    cidr_block        = "10.10.3.64/26",
    availability_zone = "eu-west-1b",
    type              = "public"
  },
  {
    cidr_block        = "10.10.3.128/26",
    availability_zone = "eu-west-1c",
    type              = "public"
  }
]
keys = []

r53zone = "YOUR_ZONE."

int_eks_nodegroups = {
  "infra-gp-burstable-medium" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "t3a.medium, t3.medium"
    desired_size        = 1
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-gp-burstable-large" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "t3a.large, t3.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-gp-burstable-xlarge" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "t3a.xlarge, t3.xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-compute-opt-large" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "c5a.large, c5.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-compute-opt-xlarge" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "c5a.xlarge, c5.xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-compute-opt-2xlarge" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "c5a.2xlarge, c5.2xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-mem-opt-large" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "r5a.large, r5.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-mem-opt-xlarge" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "r5a.xlarge, r5.xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-mem-opt-2xlarge" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "r5a.2xlarge, r5.2xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  /* Graviton requires multiarch Docker images */
  "infra-gp-graviton-large" = {
    ami_type            = "AL2_ARM_64"
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "m6g.large, m6gd.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = "NO_EXECUTE,dedicated-execution,graviton;NO_SCHEDULE,dedicated-scheduling,graviton"
    volumes             = "/dev/xvda,20,gp2"
  }
}

ext_eks_nodegroups = {
  "infra-gp-burstable-medium" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "t3a.medium, t3.medium"
    desired_size        = 1
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-gp-burstable-large" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "t3a.large, t3.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-gp-burstable-xlarge" = {
    associate_public_ip = false
    capacity_type       = "SPOT"
    instance_types      = "t3a.xlarge, t3.xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-compute-opt-large" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "c5a.large, c5.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-compute-opt-xlarge" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "c5a.xlarge, c5.xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-compute-opt-2xlarge" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "c5a.2xlarge, c5.2xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-mem-opt-large" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "r5a.large, r5.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-mem-opt-xlarge" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "r5a.xlarge, r5.xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },
  "infra-mem-opt-2xlarge" = {
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "r5a.2xlarge, r5.2xlarge"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = ""
    volumes             = "/dev/xvda,20,gp2"
  },

  /* Graviton requires multiarch Docker images
  "infra-gp-graviton-large" = {
    ami_type            = "AL2_ARM_64"
    associate_public_ip = true
    capacity_type       = "SPOT"
    instance_types      = "m6g.large, m6gd.large"
    desired_size        = 0
    min_size            = 0
    max_size            = 7
    taints              = "NO_EXECUTE,dedicated-execution,graviton;NO_SCHEDULE,dedicated-scheduling,graviton"
    volumes             = "/dev/xvda,20,gp2"
  }*/
}

common_eks_nodegroup_sg_egress_cidr_rules = [
  {
    from_port   = -1
    to_port     = -1
    protocol    = -1
    description = "Allow all outbound"
    cidr_blocks = "0.0.0.0/0"
  }
]

common_eks_nodegroup_sg_ingress_cidr_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 31080
    to_port     = 31080
    protocol    = "tcp"
    description = "Istio HTTP"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 31443
    to_port     = 31443
    protocol    = "tcp"
    description = "Istio HTTPS"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 32021
    to_port     = 32021
    protocol    = "tcp"
    description = "Istio ingress gateway healthcheck"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 31021
    to_port     = 31021
    protocol    = "tcp"
    description = "Istio eastwest gateway healthcheck"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 32443
    to_port     = 32443
    protocol    = "tcp"
    description = "Istio eastwest gateway TLS"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 32012
    to_port     = 32012
    protocol    = "tcp"
    description = "Istio discovery"
    cidr_blocks = "10.10.0.0/16"
  },
  {
    from_port   = 32017
    to_port     = 32017
    protocol    = "tcp"
    description = "Istio webhook"
    cidr_blocks = "10.10.0.0/16"
  },
]

ext_eks_nodegroup_sg_egress_cidr_rules  = []
ext_eks_nodegroup_sg_ingress_cidr_rules = []
int_eks_nodegroup_sg_egress_cidr_rules  = []
int_eks_nodegroup_sg_ingress_cidr_rules = []
