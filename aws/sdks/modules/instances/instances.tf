
resource "aws_instance" "app_server" {
  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.extra_sgs
  user_data              = data.template_file.user_data.rendered
  key_name               = var.key_pair_name

  tags = {
    Name = "${var.name}-${count.index}"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/${var.template_filename}")

  vars = {
    packages   = var.extra_packages
    nameserver = var.external_nameserver
  }
}
