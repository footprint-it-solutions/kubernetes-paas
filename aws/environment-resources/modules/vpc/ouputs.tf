output "int_vpc_id" {
  value       = aws_vpc.int_vpc.id
  description = "The ID of the INT VPC"
}
output "ext_vpc_id" {
  value       = aws_vpc.ext_vpc.id
  description = "The ID of the EXT VPC"
}
output "igw_id" {
  value       = aws_internet_gateway.ext_gw.id
  description = "The ID of the Internet Gateway"
}

output "int_security_group_id" {
  value       = aws_security_group.int_vpc_custom_sg.id
  description = "The ID of the custom security group"
}

output "ext_security_group_id" {
  value       = aws_security_group.ext_vpc_custom_sg.id
  description = "The ID of the custom security group"
}

output "pcx_id" {
  value = aws_vpc_peering_connection.pcx.id
}

output "subnet_ids" {
  value = {
    public_subnet_ids  = aws_subnet.public_subnet.*.id
    private_subnet_ids = aws_subnet.private_subnet.*.id
  }
}

output "route_tables" {
  value = {
    private_route_table_id = aws_route_table.private_rt.id
    public_route_table_id  = aws_route_table.public_rt.id
  }
}
