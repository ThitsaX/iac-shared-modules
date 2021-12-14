output "public_ip" {
  value = var.internal_lb ? null : aws_eip.nlb[0].public_ip
}
output "public_dns" {
  value = var.internal_lb ? null : aws_eip.nlb[0].public_dns
}
output "private_ip" {
  value = var.internal_lb ? null : aws_eip.nlb[0].private_ip
}
output "private_dns" {
  value = var.internal_lb ? aws_lb.nlb.dns_name : aws_eip.nlb[0].private_dns
}
