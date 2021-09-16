output "public_ip" {
  value = aws_instance.wireguard.public_ip
}

output "private_ip" {
  value = aws_instance.wireguard.private_ip
}

output "hostname" {
  value = "wireguard.${var.cert_domain}"
}