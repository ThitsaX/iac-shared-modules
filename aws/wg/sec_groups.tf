data "aws_subnet" "selected" {
  id = var.subnet_id
}
resource "aws_security_group" "wireguard_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.wireguard_tenancy_name}-wireguard"
  description = "Allow all to vpn alb"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_subnet.selected.cidr_block]
  }
  ingress {
    from_port   = "51820"
    to_port     = "51820"
    protocol    = "udp"
    cidr_blocks = [data.aws_subnet.selected.cidr_block]
  }

  ingress {
    from_port   = "5000"
    to_port     = "5000"
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.selected.cidr_block]
  }

  tags = merge({}, var.tags)
}