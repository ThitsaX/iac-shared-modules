/**
 * # VPN Server
 *
 * Create EC2 instance that performs the VPN function
 *
 * Uses an inline provision to deploy  Wireguard
 *
 */

resource "aws_instance" "wireguard" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = var.security_groups
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
  provisioner "remote-exec" {
    inline = [
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
      "sudo echo DONE. PLEASE REBOOT"
    ]
  }
}
