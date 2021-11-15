resource "aws_ec2_transit_gateway" "this" {
  description = var.p2p_tran_gw_name

  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  auto_accept_shared_attachments  = "enable"

}

resource "aws_ec2_transit_gateway_route_table" "thisA" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

}

resource "aws_ec2_transit_gateway_route_table" "thisB" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

}

resource "aws_customer_gateway" "this" {
  bgp_asn    = var.cgw_bgp_asn
  ip_address = var.cgw_ip_address
  type       = "ipsec.1"

}

resource "aws_vpn_connection" "this" {
  customer_gateway_id   = aws_customer_gateway.this.id
  type                  = "ipsec.1"
  transit_gateway_id    = aws_ec2_transit_gateway.this.id
  static_routes_only    = var.static_routes_only
  tunnel1_inside_cidr   = var.tunnel1_inside_cidr
  tunnel2_inside_cidr   = var.tunnel2_inside_cidr
  tunnel1_preshared_key = var.phase1_vpn_config["phase1_tunnel1_preshared_key"]
  tunnel2_preshared_key = var.phase1_vpn_config["phase1_tunnel2_preshared_key"]
  /*   tunnel1_ike_versions = toset(var.phase1_vpn_config["phase1_ike_versions"])
  tunnel2_ike_versions = toset(var.phase1_vpn_config["phase1_ike_versions"]) */
  tunnel1_phase1_dh_group_numbers      = ["${var.phase1_vpn_config["phase1_dh_group_numbers"]}"]
  tunnel2_phase1_dh_group_numbers      = ["${var.phase1_vpn_config["phase1_dh_group_numbers"]}"]
  tunnel1_phase1_encryption_algorithms = ["${var.phase1_vpn_config["phase1_encryption_algorithms"]}"]
  tunnel2_phase1_encryption_algorithms = ["${var.phase1_vpn_config["phase1_encryption_algorithms"]}"]
  tunnel1_phase1_integrity_algorithms  = ["${var.phase1_vpn_config["phase1_integrity_algorithms"]}"]
  tunnel2_phase1_integrity_algorithms  = ["${var.phase1_vpn_config["phase1_integrity_algorithms"]}"]
  tunnel1_phase2_dh_group_numbers      = ["${var.phase2_vpn_config["phase2_dh_group_numbers"]}"]
  tunnel2_phase2_dh_group_numbers      = ["${var.phase2_vpn_config["phase2_dh_group_numbers"]}"]
  tunnel1_phase2_encryption_algorithms = ["${var.phase2_vpn_config["phase2_encryption_algorithms"]}"]
  tunnel2_phase2_encryption_algorithms = ["${var.phase2_vpn_config["phase2_encryption_algorithms"]}"]
  tunnel1_phase2_integrity_algorithms  = ["${var.phase2_vpn_config["phase2_integrity_algorithms"]}"]
  tunnel2_phase2_integrity_algorithms  = ["${var.phase2_vpn_config["phase2_integrity_algorithms"]}"]

}

resource "aws_ec2_transit_gateway_route" "this" {
  destination_cidr_block         = var.vpn_cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.thisA.id
  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
}

resource "aws_ec2_transit_gateway_route_table_association" "thisB" {

  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.thisB.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "thisA" {
  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.thisA.id
}

module "tgw-attachments" {
  source                                          = "./tgw-attachments"
  count                                           = length(var.k3svpc)
  vpc_name                                        = var.k3svpc[count.index]
  transit_gateway_id                              = aws_ec2_transit_gateway.this.id
  aws_ec2_transit_gateway_route_table_A           = aws_ec2_transit_gateway_route_table.thisA.id
  aws_ec2_transit_gateway_route_table_B           = aws_ec2_transit_gateway_route_table.thisB.id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
}

module "pm4ml-routes-side-a" {
  depends_on = [aws_ec2_transit_gateway.this]
  source     = "./pm4ml-routes-side"
  /*   count                  = length(var.pm4ml_routes_table_names) */
  route_table_ids        = data.aws_route_tables.a.ids
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
  destination_cidr_block = var.vpn_cidr_block

}

module "pm4ml-routes-side-b" {
  depends_on = [aws_ec2_transit_gateway.this]
  source     = "./pm4ml-routes-side"
  /*   count                  = length(var.pm4ml_routes_table_names) */
  route_table_ids        = data.aws_route_tables.b.ids
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
  destination_cidr_block = var.vpn_cidr_block

}


/* resource "aws_ec2_transit_gateway_route" "this" {
  count                          = var.static_routes_only ? length(var.static_routes_destinations) : 0
  destination_cidr_block         = element(var.static_routes_destinations, count.index)
  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
} */
