output "public_ip" {
  value = aws_eip.nlb.public_ip
}
output "public_dns" {
  value = aws_eip.nlb.public_dns
}
output "private_ip" {
  value = aws_eip.nlb.private_ip
}
output "private_dns" {
  value = aws_eip.nlb.private_dns
}
