variable "transit_gateway_id" {

}

variable "route_table_ids" {

}

variable "destination_cidr_block" {

}


resource "aws_route" "this" {
  for_each               = var.route_table_ids
  route_table_id         = tolist(each.value)
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id

}
