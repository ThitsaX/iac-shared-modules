variable "vpc_id" {
}

variable "environment" {
}

variable "ssh_port" {
}

variable "vpn_port" {
}

variable "ami" {
}

variable "instance_type" {
}

variable "key_name" {
}

variable "subnet_id" {
}

variable "osuser" {
}

variable "pvt_key" {
  default = ""
}

variable "pvt_key_content" {
  default = ""
}

variable "bastion_host" {
}

variable "host_name" {
}
/*
variable "private_ip" {
}*/
variable "cidr_block" {

}
/*
variable "oct1" {
}

variable "oct2m" {
}

variable "oct2s" {
}
*/
variable "ospassword" {
}

resource "template_file" "install_openvpn" {
  template = file("${path.module}/assets/install_openvpn.sh")
  vars = {
    ospassword = var.ospassword
  }
}

resource "aws_security_group" "openvpn_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.environment}-${var.host_name}-host"
  description = "Allow all to openvpn host"

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

  tags = {
    Name        = "${var.environment}-${var.host_name}-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "openvpn" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.openvpn_sg.id]
  subnet_id                   = var.subnet_id
#  private_ip                  = var.private_ip
  associate_public_ip_address = true

  tags = {
    Name        = "${var.environment}-${var.host_name}"
    Environment = var.environment
  }

  connection {
    type = "ssh"
    user = var.osuser

    //RPM migration to v0.12 requires host
    host                = self.private_ip
    agent               = false
    private_key         = (var.pvt_key != "" ? file(var.pvt_key) : var.pvt_key_content)
    bastion_host        = var.bastion_host
    bastion_user        = var.osuser
    bastion_private_key = (var.pvt_key != "" ? file(var.pvt_key) : var.pvt_key_content)
  }

  provisioner "file" {
    content     = template_file.install_openvpn.rendered
    destination = "/home/${var.osuser}/install_openvpn.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.osuser}/*",
      "sudo /home/${var.osuser}/install_openvpn.sh",
      "sudo /usr/local/openvpn_as/scripts/sacli -k admin_ui.https.port -v 443 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k cs.ssl_method -v SSLv3 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k cs.ssl_reneg -v true ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k cs.tls_version_min -v 1.2 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k cs.https.port -v 443 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k host.name -v ${aws_instance.openvpn.public_ip} ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.daemon.tcp.n_daemons -v 1 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.daemon.tcp.port -v ${var.vpn_port} ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.daemon.udp.n_daemons -v 1 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.daemon.udp.port -v ${var.vpn_port} ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.daemon.0.listen.port -v 443 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.routing.private_network.0 -v ${var.cidr_block} ConfigPut",
 #     "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.routing.private_network.0 -v ${var.oct1}.${var.oct2m}.0.0/22 ConfigPut",
 #     "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.routing.private_network.1 -v ${var.oct1}.${var.oct2s}.0.0/16 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.tls_auth -v true ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli -k vpn.server.tls_version_min -v 1.2 ConfigPut",
      "sudo /usr/local/openvpn_as/scripts/sacli start",
    ]
  }
}

output "openvpn_public_ip" {
  value = aws_instance.openvpn.public_ip
}

output "openvpn_ip" {
  value = aws_instance.openvpn.private_ip
}

