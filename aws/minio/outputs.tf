output "instance_id" {
  value       = aws_instance.minio.id
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
  value = aws_route53_record.minio-private.fqdn
}

output "server_private_ip" {
  value       = aws_instance.minio.private_ip
  description = "Private IP of minio server"
}

output "minio_ssh_private_key" {
  description = "Private SSH key for minio Server"
  value       = tls_private_key.minio_provisioner_key.private_key_pem
  sensitive   = true
}

output "minio_ssh_public_key" {
  description = "Public SSH key for minio Server"
  value       = tls_private_key.minio_provisioner_key.public_key_openssh
}

output "minio_docker_repo_port" {
  description = "minio docker repo port"
  value       = var.docker_repo_listening_port
}
output "minio_admin_pw" {
  description = "minio admin pw"
  value       = local.minio_admin_password
}
