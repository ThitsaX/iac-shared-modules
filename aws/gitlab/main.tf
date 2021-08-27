/**
 * # GitLab and GitLab CI Module
 *
 * Create GitLab server and CI runner using EC2 instances.
 *
 * The module creates 2 EC2 instances, one for GitLab server. The other for the GitLab CI runner. It configures the CI runner with the GitLab server so that CICD job can immediately be run.
 *
 * Configuration of GitLab and GitLab CI runner is done by Ansible using the roles included in this module.
 *
 */

module "label" {
  source     = "../null-label"
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "ssh_key_pair" {
  source              = "../key-pair"
  generate_ssh_key    = "true"
  name                = coalesce(var.key_name, "${var.namespace}-${var.name}") # This is a little ugly but is so that we can preserve backwards compatibility with existing environments and allow manually overwriting the key name
  ssh_public_key_path = "${path.module}/ssh_keys/"
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
  key_name                    = coalesce(var.key_name, module.ssh_key_pair.key_name)
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
      private_key = file(module.ssh_key_pair.private_key_filename)
    }
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_instance" "gitlab-ci" {
  ami                         = var.ami
  instance_type               = var.gitlab_runner_size
  vpc_security_group_ids      = compact(concat([aws_security_group.default.id], var.security_groups))
  iam_instance_profile        = aws_iam_instance_profile.default.name
  associate_public_ip_address = "true"
  key_name                    = coalesce(var.key_name, module.ssh_key_pair.key_name)
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
      private_key = file(module.ssh_key_pair.private_key_filename)
    }
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

module "dns" {
  source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.10.0"
  name    = var.name
  zone_id = var.zone_id
  ttl     = 300
  records = [aws_instance.gitlab-server.public_dns]
}

# Create Ansible Inventory file
resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    ssh_user               = var.ssh_user
    ssh_key                = "./ssh_keys/${module.ssh_key_pair.key_name}"
    gitlab_server_hostname = aws_instance.gitlab-server.public_dns
    gitlab_ci_hostname     = aws_instance.gitlab-ci.public_dns
  })
  filename        = "${path.module}/inventory"
  file_permission = "0644"
}

resource "random_password" "gitlab_root_password" {
  length = 16
  special = true
}

resource "null_resource" "configure-gitlab" {
  provisioner "local-exec" {
    command     = "ansible-playbook -i inventory gitlab.yaml --extra-vars 'server_password=${random_password.gitlab_root_password.result} external_url=https://${module.dns.hostname}/ enable_pages=false server_hostname=${module.dns.hostname}'"
    working_dir = path.module
  }
  depends_on = [aws_instance.gitlab-server, aws_instance.gitlab-ci]
}
