
resource "aws_vpc" "int_vpc" {
  cidr_block           = var.int_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = "int-vpc"
  }
}

resource "aws_vpc_endpoint" "int_vpc_ecr_api" {
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.int_vpc_custom_sg.id
  ]

  service_name      = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids        = aws_subnet.private_endpoint_subnet.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.int_vpc.id
}

resource "aws_vpc_endpoint" "int_vpc_ecr_dkr" {
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.int_vpc_custom_sg.id
  ]

  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids        = aws_subnet.private_endpoint_subnet.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.int_vpc.id
}

resource "aws_vpc_endpoint" "int_vpc_s3" {
  vpc_id       = aws_vpc.int_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc" "ext_vpc" {
  cidr_block           = var.ext_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = "ext-vpc"
  }
}

resource "aws_vpc_endpoint" "ext_vpc_ecr_api" {
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.ext_vpc_custom_sg.id
  ]

  service_name      = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids        = aws_subnet.public_subnet.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.ext_vpc.id
}

resource "aws_vpc_endpoint" "ext_vpc_ecr_dkr" {
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.ext_vpc_custom_sg.id
  ]

  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids        = aws_subnet.public_subnet.*.id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.ext_vpc.id
}

resource "aws_vpc_endpoint" "ext_vpc_s3" {
  vpc_id       = aws_vpc.ext_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_ipv4_cidr_block_association" "vpc_endpoints" {
  vpc_id     = aws_vpc.int_vpc.id
  cidr_block = "100.64.10.0/24"
}

resource "aws_security_group" "int_vpc_custom_sg" {
  vpc_id = aws_vpc.int_vpc.id

  tags = {
    Name = "int VPC Security Group"
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = egress.value["description"]
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      protocol    = egress.value["protocol"]
      cidr_blocks = egress.value["cidr_blocks"]
    }
  }
}

resource "aws_security_group" "ext_vpc_custom_sg" {
  vpc_id = aws_vpc.ext_vpc.id

  tags = {
    Name = "ext VPC Security Group"
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = egress.value["description"]
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      protocol    = egress.value["protocol"]
      cidr_blocks = egress.value["cidr_blocks"]
    }
  }
}

resource "aws_internet_gateway" "ext_gw" {
  vpc_id = aws_vpc.ext_vpc.id

  tags = {
    Name = "EXT Internet Gateway"
  }
}


resource "aws_vpc_peering_connection" "pcx" {
  peer_vpc_id = aws_vpc.int_vpc.id
  vpc_id      = aws_vpc.ext_vpc.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}
