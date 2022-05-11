/**
 * # minio Module
 *
 * Create minio server using EC2 instance.
 *
 * The module creates an EC2 instance. It configures minio using a docker instance.
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

resource "random_password" "minio_password" {
  length  = 16
  special = true
  override_special = "@#*"
}

resource "random_password" "minio_root_user" {
  length  = 16
  special = false
}

resource "aws_key_pair" "minio_provisioner_key" {
  key_name   = "minio-${var.namespace}-${var.domain}-deployer-key"
  public_key = tls_private_key.minio_provisioner_key.public_key_openssh

  tags = var.tags
}

resource "tls_private_key" "minio_provisioner_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "minio_provisioner_key" {
  content         = tls_private_key.minio_provisioner_key.private_key_pem
  filename        = "${path.module}/minio_ssh_provisioner_key"
  file_permission = "0600"
}

resource "local_file" "minio_provisioner_public_key" {
  content  = tls_private_key.minio_provisioner_key.public_key_openssh
  filename = "${path.module}/minio_ssh_provisioner_public_key"
}

resource "aws_iam_instance_profile" "default" {
  name = "${replace(var.domain, ".", "-")}-${var.tenant}-minio"
  role = aws_iam_role.default.name
}

resource "aws_iam_role" "default" {
  name = "${replace(var.domain, ".", "-")}-${var.tenant}-minio"
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
  description = "minio security group"

  tags = module.label.tags

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "minio access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.docker_repo_allowed_cidr_blocks
  }

  ingress {
    description = "minio console access"
    from_port   = 9001
    to_port     = 9001
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

resource "aws_instance" "minio" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = compact(concat([aws_security_group.default.id], var.security_groups))
  iam_instance_profile        = aws_iam_instance_profile.default.name
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.minio_provisioner_key.key_name
  subnet_id                   = var.subnets[0]
  tags                        = merge({ Name = "minio" }, module.label.tags)
  volume_tags                 = merge({ Name = "minio" }, module.label.tags)
  root_block_device {
    delete_on_termination = var.delete_storage_on_term
    volume_type           = "gp2"
    volume_size           = 100
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_route53_record" "minio-private" {
  zone_id = var.zone_id
  name    = var.name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.minio.private_ip]
}

# Create Ansible Inventory file
resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    ssh_user       = var.ssh_user
    ssh_key        = "./minio_ssh_provisioner_key"
    minio_hostname = aws_instance.minio.public_ip
  })
  filename        = "${path.module}/inventory"
  file_permission = "0644"
  depends_on      = [local_file.minio_provisioner_key]
}

resource "null_resource" "configure-minio" {
  provisioner "local-exec" {
    command     = "ansible-galaxy collection install community.docker && ansible-playbook -i inventory minio.yaml --extra-vars 'root_pw=${local.minio_admin_password} root_user=${local.minio_root_user}'"
    working_dir = path.module
  }
  depends_on = [aws_instance.minio, local_file.ansible-inventory]
}

locals {
  minio_admin_password = var.minio_admin_password == "" ? random_password.minio_password.result : var.minio_admin_password
  minio_root_user = random_password.minio_root_user.result
}
