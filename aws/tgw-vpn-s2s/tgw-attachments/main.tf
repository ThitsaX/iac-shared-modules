variable "vpc_name" {

}

variable "transit_gateway_id" {

}

variable "transit_gateway_default_route_table_association" {

}

variable "transit_gateway_default_route_table_propagation" {

}

variable "aws_ec2_transit_gateway_route_table_A" {

}

variable "aws_ec2_transit_gateway_route_table_B" {

}

data "aws_vpc" "this" {
  filter {
    name   = "state"
    values = ["available"]
  }

   filter {
     name = "tag-value"
     values = ["${var.vpc_name}"]
   }

   filter {
     name = "tag-key"
     values = ["Name"]
   }

}

data "aws_subnet_ids" "this" {
    vpc_id = data.aws_vpc.this.id

    filter {
      name = "tag-value"
      values = ["*private*"]
    }

    filter {
      name = "tag-key"
      values = ["Name"]
    }

}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id = data.aws_vpc.this.id
  subnet_ids = data.aws_subnet_ids.this.ids
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

}

resource "aws_ec2_transit_gateway_route_table_association" "thisA" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.aws_ec2_transit_gateway_route_table_A
}

resource "aws_ec2_transit_gateway_route_table_propagation" "thisB" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.aws_ec2_transit_gateway_route_table_B
}