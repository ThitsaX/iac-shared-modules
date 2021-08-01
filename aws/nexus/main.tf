/**
 * # Nexus Module
 *
 * Create Nexus server using EC2 instance.
 *
 * The module creates an EC2 instance. It configures Nexus using a docker instance.
 *
 * Configuration is done by Ansible using the roles included in this module.
 *
 */

module "label" {
  source     = "../null-label"
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "random_password" "nexus_password" {
  length  = 16
  special = true
}

resource "aws_key_pair" "nexus_provisioner_key" {
  key_name   = "nexus-${var.namespace}-${var.domain}-deployer-key"
  public_key = tls_private_key.nexus_provisioner_key.public_key_openssh

  tags = var.tags
}

resource "tls_private_key" "nexus_provisioner_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "nexus_provisioner_key" {
  content         = tls_private_key.nexus_provisioner_key.private_key_pem
  filename        = "${path.module}/nexus_ssh_provisioner_key"
  file_permission = "0600"
}

resource "local_file" "nexus_provisioner_public_key" {
  content  = tls_private_key.nexus_provisioner_key.public_key_openssh
  filename = "${path.module}/nexus_ssh_provisioner_public_key"
}

resource "aws_iam_instance_profile" "default" {
  name = "${replace(var.domain, ".", "-")}-nexus"
  role = aws_iam_role.default.name
}

resource "aws_iam_role" "default" {
  name = "${replace(var.domain, ".", "-")}-nexus"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_security_group" "default" {
  name        = module.label.id
  vpc_id      = var.vpc_id
  description = "Nexus security group"

  tags = module.label.tags

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "nexus admin access"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.docker_repo_allowed_cidr_blocks
  }

  ingress {
    description = "docker repo http access"
    from_port   = var.docker_repo_listening_port
    to_port     = var.docker_repo_listening_port
    protocol    = "tcp"
    cidr_blocks = var.docker_repo_allowed_cidr_blocks
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "nexus" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = compact(concat([aws_security_group.default.id], var.security_groups))
  iam_instance_profile        = aws_iam_instance_profile.default.name
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.nexus_provisioner_key.key_name
  subnet_id                   = var.subnets[0]
  tags                        = merge({ Name = "nexus" }, module.label.tags)
  volume_tags                 = merge({ Name = "nexus" }, module.label.tags)
  root_block_device {
    delete_on_termination = false
    volume_type           = "gp2"
    volume_size           = 100
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_route53_record" "nexus-private" {
  zone_id = var.zone_id
  name    = var.name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.nexus.private_ip]
}

# Create Ansible Inventory file
resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    ssh_user       = var.ssh_user
    ssh_key        = "./nexus_ssh_provisioner_key"
    nexus_hostname = aws_instance.nexus.public_ip
  })
  filename        = "${path.module}/inventory"
  file_permission = "0644"
  depends_on      = [local_file.nexus_provisioner_key]
}

resource "null_resource" "configure-nexus" {
  provisioner "local-exec" {
    command     = "ansible-galaxy collection install community.general && ansible-playbook -i inventory nexus.yaml --extra-vars 'new_admin_pw=${local.nexus_admin_password} docker_group_listening_port=${var.docker_repo_listening_port}'"
    working_dir = path.module
  }
  depends_on = [aws_instance.nexus, local_file.ansible-inventory]
}

locals {
  nexus_admin_password = var.nexus_admin_password == "" ? random_password.nexus_password.result : var.nexus_admin_password
}
