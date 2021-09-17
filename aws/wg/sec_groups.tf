resource "aws_security_group" "alb_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.wireguard_tenancy_name}-wireguard-alb"
  description = "Allow all to vpn alb"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({}, var.tags)
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

  ingress {
    from_port   = "51820"
    to_port     = "51820"
    protocol    = "udp"
    cidr_blocks = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = "5000"
    to_port     = "5000"
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.alb_sg.id]
  }

  tags = merge({}, var.tags)
}