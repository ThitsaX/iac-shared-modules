output "publicIPs" {
  value = aws_instance.app_server[*].public_ip
}

output "hosts" {
  value = aws_route53_record.instance_dns[*].name
}
