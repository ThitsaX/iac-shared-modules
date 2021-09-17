/**
 * # VPN Server
 *
 * Create EC2 instance that performs the VPN function
 *
 * Uses an inline provision to deploy  Wireguard
 *
 */

data "template_file" "wgui_service" {
  template = file("${path.module}/assets/wgui.service.tpl")

  vars = {
    wgui_password = var.ui_admin_pw
  }
}

resource "aws_instance" "wireguard" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.wireguard_sg.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = merge({
    Name = "wireguard"
  }, var.tags)

  connection {
    type = "ssh"
    user = "ubuntu"

    host        = self.public_ip
    agent       = false
    private_key = var.ssh_key
  }
  
  provisioner "file" {
    source      = "${path.module}/assets/wg0.conf"
    destination = "/tmp/wg0.conf"
  }
  provisioner "file" {
    source      = "${path.module}/assets/wg-autoreload.path"
    destination = "/tmp/wg-autoreload.path"
  }
  provisioner "file" {
    source      = "${path.module}/assets/wg-autoreload.service"
    destination = "/tmp/wg-autoreload.service"
  }
  provisioner "file" {
    content      = data.template_file.wgui_service.rendered
    destination = "/tmp/wgui.service"
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 120",
      "sudo DEBIAN_FRONTEND=noninteractive apt update",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -q -y wireguard || exit 1",
      "umask 077; sudo wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey  | sudo tee /etc/wireguard/publickey",
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "sudo sysctl -A | sudo tee /etc/sysctl.conf",
      "sudo mv /tmp/wg0.conf /etc/wireguard/wg0.conf",
      "sudo chmod 0600 /etc/wireguard/wg0.conf",
      "sudo chown root:root /etc/wireguard/wg0.conf",
      "sudo sed -e \"s@##MYKEY##@$(sudo cat /etc/wireguard/privatekey)@\" -i /etc/wireguard/wg0.conf",
      "sudo systemctl enable wg-quick@wg0",
      "sudo systemctl restart wg-quick@wg0",
      "cd /tmp",
      "wget https://github.com/ngoduykhanh/wireguard-ui/releases/download/v0.3.2/wireguard-ui-v0.3.2-linux-amd64.tar.gz",
      "tar -xzvf wireguard-ui-v0.3.2-linux-amd64.tar.gz",
      "sudo mv wireguard-ui /usr/local/bin",
      "sudo cp /tmp/wgui.service /tmp/wg-autoreload.service /tmp/wg-autoreload.path /etc/systemd/system/",
      "sudo systemctl enable wgui.service wg-autoreload.service wg-autoreload.path",
      "sudo systemctl restart wgui.service wg-autoreload.service wg-autoreload.path",
      "sudo echo DONE"
    ]
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
