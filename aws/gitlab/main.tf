module "label" {
  source     = "git@github.com:modusintegration/terraform-shared-modules.git//aws/terraform-null-label"
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_key_pair" "gitlab_provisioner_key" {
  key_name   = "gitlab-${var.namespace}-${var.domain}-deployer-key"
  public_key = tls_private_key.gitlab_provisioner_key.public_key_openssh

  tags = var.tags
}

resource "tls_private_key" "gitlab_provisioner_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "gitlab_provisioner_key" {
  content         = tls_private_key.gitlab_provisioner_key.private_key_pem
  filename        = "${path.module}/gitlab_ssh_provisioner_key"
  file_permission = "0600"
}

resource "local_file" "gitlab_provisioner_public_key" {
  content         = tls_private_key.gitlab_provisioner_key.public_key_openssh
  filename        = "${path.module}/gitlab_ssh_provisioner_public_key"
}

resource "aws_iam_instance_profile" "default" {
  name = "${replace(var.domain, ".", "-")}-gitlab"
  role = aws_iam_role.default.name
}

resource "aws_iam_role" "default" {
  name = "${replace(var.domain, ".", "-")}-gitlab"
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
  description = "GitLab security group (SSH, HTTP/S inbound access is allowed)"

  tags = module.label.tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "GitLab Container Registry"
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

resource "aws_instance" "gitlab-server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  user_data                   = var.user_data
  vpc_security_group_ids      = compact(concat([aws_security_group.default.id], var.security_groups))
  iam_instance_profile        = aws_iam_instance_profile.default.name
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.gitlab_provisioner_key.key_name
  subnet_id                   = var.subnets[0]
  tags                        = merge({ Snapshot = var.fqdn }, module.label.tags)
  volume_tags                 = merge({ Snapshot = var.fqdn }, module.label.tags)
  root_block_device {
    delete_on_termination = false
    volume_type           = "gp2"
    volume_size           = 100
  }

  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = 100
  }

  provisioner "remote-exec" {
    inline = ["python3 --version || sudo apt -y install python3 python3-pip"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.gitlab_provisioner_key.private_key_pem
    }
  }
  depends_on = [local_file.gitlab_provisioner_key]
}

resource "aws_instance" "gitlab-ci" {
  ami           = var.ami
  instance_type = var.gitlab_runner_size
  vpc_security_group_ids      = compact(concat([aws_security_group.default.id], var.security_groups))
  iam_instance_profile        = aws_iam_instance_profile.default.name
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.gitlab_provisioner_key.key_name
  subnet_id                   = var.subnets[0]
  tags                        = merge(module.label.tags, { "Name" = "gitlab-runner" })
  volume_tags                 = merge({ Snapshot = var.fqdn }, module.label.tags)
  root_block_device {
    delete_on_termination = false
    volume_type           = "gp2"
    volume_size           = 40
  }

  provisioner "remote-exec" {
    inline = ["python3 --version || sudo apt -y install python3 python3-pip"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.gitlab_provisioner_key.private_key_pem
    }
  }
  depends_on = [local_file.gitlab_provisioner_key]
}

module "dns" {
  source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.3.0"
  name    = var.name
  zone_id = var.zone_id
  ttl     = 300
  records = [aws_instance.gitlab-server.public_dns]
}

# Create Ansible Inventory file
resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    ssh_user               = var.ssh_user
    ssh_key                = "./gitlab_ssh_provisioner_key"
    gitlab_server_hostname = aws_instance.gitlab-server.public_dns
    gitlab_ci_hostname     = aws_instance.gitlab-ci.public_dns
  })
  filename        = "${path.module}/inventory"
  file_permission = "0644"
  depends_on = [local_file.gitlab_provisioner_key]
}

resource "null_resource" "configure-gitlab" {
  provisioner "local-exec" {
    command     = "ansible-playbook -i inventory gitlab.yaml --extra-vars 'external_url=https://${module.dns.hostname}/ enable_pages=false server_hostname=${module.dns.hostname}'"
    working_dir = path.module
  }
  depends_on = [aws_instance.gitlab-server, aws_instance.gitlab-ci, local_file.ansible-inventory]
}
