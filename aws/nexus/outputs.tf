output "instance_id" {
  value       = aws_instance.nexus.id
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
  value = aws_route53_record.nexus-private.fqdn
}

output "server_private_ip" {
  value       = aws_instance.nexus.private_ip
  description = "Private IP of nexus server"
}

output "nexus_ssh_private_key" {
  description = "Private SSH key for Nexus Server"
  value       = tls_private_key.nexus_provisioner_key.private_key_pem
  sensitive   = true
}

output "nexus_ssh_public_key" {
  description = "Public SSH key for Nexus Server"
  value       = tls_private_key.nexus_provisioner_key.public_key_openssh
}

output "nexus_docker_repo_port" {
  description = "nexus docker repo port"
  value       = var.docker_repo_listening_port
}
output "nexus_admin_pw" {
  description = "nexus admin pw"
  value       = local.nexus_admin_password
}
