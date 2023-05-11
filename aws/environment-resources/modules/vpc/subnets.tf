resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_info)

  vpc_id                  = aws_vpc.ext_vpc.id
  cidr_block              = var.public_subnet_info[count.index].cidr_block
  availability_zone       = var.public_subnet_info[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "public-${var.public_subnet_info[count.index].availability_zone}",
    "kubernetes.io/cluster/${var.ext_eks_name}" = "shared"
  }
}

resource "aws_route_table_association" "rt_association_public" {
  count          = length(var.public_subnet_info)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ext_vpc.id
  tags = {
    "Name" = "public_route_table"
  }
}
resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.ext_gw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "public_to_intvpc" {
  route_table_id            = aws_route_table.public_rt.id
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id
  destination_cidr_block    = var.int_cidr_block
}

####
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_info)

  vpc_id                  = aws_vpc.int_vpc.id
  cidr_block              = var.private_subnet_info[count.index].cidr_block
  availability_zone       = var.private_subnet_info[count.index].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "private-${var.private_subnet_info[count.index].availability_zone}",
    "kubernetes.io/cluster/${var.int_eks_name}" = "shared"
  }
}

resource "aws_subnet" "private_endpoint_subnet" {
  count = length(var.private_endpoint_subnet_info)

  vpc_id                  = aws_vpc.int_vpc.id
  cidr_block              = var.private_endpoint_subnet_info[count.index].cidr_block
  availability_zone       = var.private_subnet_info[count.index].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "private-endpoint-${var.private_subnet_info[count.index].availability_zone}"
  }
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_endpoints
  ]
}

resource "aws_route_table_association" "rt_association_private" {
  count          = length(var.private_subnet_info)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.int_vpc.id
  tags = {
    "Name" = "private_route_table"
  }
}
resource "aws_route" "private_to_extvpc" {
  route_table_id            = aws_route_table.private_rt.id
  vpc_peering_connection_id = aws_vpc_peering_connection.pcx.id
  destination_cidr_block    = var.ext_vpc_cidr
}
