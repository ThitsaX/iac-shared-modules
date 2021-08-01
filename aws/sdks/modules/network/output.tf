output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "ssh_security_group_id" {
  value = aws_security_group.ssh.id
}

output "sdk_security_group_id" {
  value = aws_security_group.sdk.id
}

output "cbsadapter_security_group_id" {
  value = aws_security_group.cbsadapter.id
}

output "kubeapi_security_group_id" {
  value = aws_security_group.kubeapi.id
}
