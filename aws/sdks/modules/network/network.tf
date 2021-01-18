resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidrs.public
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "PublicAZA" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidrs.private
  map_public_ip_on_launch = false
}

resource "aws_route_table_association" "PrivateAZA" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "ssh" {
  name        = "SSH SG"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allow_ssh_access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cbsadapter" {
  name        = "cbsadapter"
  description = "cbsadapter"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3500
    protocol    = "tcp"
    cidr_blocks = var.allow_cbs_access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sdk" {
  name        = "sdk"
  description = "sdk"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 4000
    to_port     = 4500
    protocol    = "tcp"
    cidr_blocks = var.allow_sdk_access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kubeapi" {
  name        = "kube api"
  description = "kube api"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.allow_k3s_access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet gw terraform generated"
  }
}

resource "aws_network_acl" "all" {
  vpc_id = aws_vpc.vpc.id
  egress {
    protocol   = "-1"
    rule_no    = 2
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 1
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "open acl"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.PublicAZA.id
  }
}

resource "aws_eip" "forNat" {
  vpc = true
}

resource "aws_nat_gateway" "PublicAZA" {
  allocation_id = aws_eip.forNat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.gw]
}
