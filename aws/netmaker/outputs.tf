output "instance_id" {
  value       = aws_instance.netmaker.id
  description = "Instance ID"
}

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH user"
}

output "security_group_id" {
  value       = aws_security_group.default.id
  description = "Security group ID"
}

output "role" {
  value       = aws_iam_role.default.name
  description = "Name of AWS IAM Role associated with the instance"
}

output "server_hostname" {
  value = aws_route53_record.netmaker-private.fqdn
}

output "server_private_ip" {
  value       = aws_instance.netmaker.private_ip
  description = "Private IP of netmaker server"
}

output "netmaker_ssh_private_key" {
  description = "Private SSH key for netmaker Server"
  value       = tls_private_key.netmaker_provisioner_key.private_key_pem
  sensitive   = true
}

output "netmaker_ssh_public_key" {
  description = "Public SSH key for netmaker Server"
  value       = tls_private_key.netmaker_provisioner_key.public_key_openssh
}

output "netmaker_docker_repo_port" {
  description = "netmaker docker repo port"
  value       = var.docker_repo_listening_port
}
output "netmaker_admin_pw" {
  description = "netmaker admin pw"
  value       = local.netmaker_admin_password
}
