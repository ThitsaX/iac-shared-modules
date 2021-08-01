resource null_resource "setup-users" {
 connection {
    type = "ssh"
    user = "ubuntu"

    host                = var.wireguard_address
    agent               = false
    private_key         = var.ssh_key
  }

  provisioner "file" {
    content      = file("${path.module}/assets/create_profile.sh")
    destination  = "/tmp/create_profile.sh"
  }

  provisioner "remote-exec" {
    inline = [
    "which wg || (echo Wireguard not installed. Aborting ... &&  exit 1)",
    "sudo cp /tmp/create_profile.sh /usr/bin/",
    "sudo chmod 0755 /usr/bin/create_profile.sh",
    "for i in `seq 1 ${var.id}`; do sudo /usr/bin/create_profile.sh $i ${var.dns_server} ${var.wireguard_address}:51820 \"Bootstrap profile $i\"; done"
    ]
  }

}



