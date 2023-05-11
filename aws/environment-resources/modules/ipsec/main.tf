resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = var.customer_ip
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id                       = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id                  = aws_customer_gateway.customer_gateway.id
  type                                 = "ipsec.1"
  static_routes_only                   = true
  tunnel1_dpd_timeout_action           = "restart"
  tunnel2_dpd_timeout_action           = "restart"
  tunnel1_ike_versions                 = ["ikev2"]
  tunnel2_ike_versions                 = ["ikev2"]
  tunnel1_phase1_dh_group_numbers      = [16]
  tunnel2_phase1_dh_group_numbers      = [16]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers      = [16]
  tunnel2_phase2_dh_group_numbers      = [16]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel1_preshared_key                = var.t1_pskey
  tunnel2_preshared_key                = var.t2_pskey
  tunnel1_startup_action               = "start"
  tunnel2_startup_action               = "start"
}

resource "aws_vpn_connection_route" "on-prem" {
  destination_cidr_block = "0.0.0.0/0"
  vpn_connection_id      = aws_vpn_connection.main.id
}

resource "aws_route" "internet_via_onprem" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_route53_record" "t1" {
  zone_id = var.r53zone_id
  name    = "t1.${var.region}.${var.r53zone_name}"
  type    = "A"
  ttl     = "150"
  records = [aws_vpn_connection.main.tunnel1_address]
}

resource "aws_route53_record" "t2" {
  zone_id = var.r53zone_id
  name    = "t2.${var.region}.${var.r53zone_name}"
  type    = "A"
  ttl     = "150"
  records = [aws_vpn_connection.main.tunnel2_address]
}

output "ip" {
  value = {
    t1_ip = aws_vpn_connection.main.tunnel1_address
    t2_ip = aws_vpn_connection.main.tunnel2_address
  }
}
