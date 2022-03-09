output "instance_id" {
  value       = aws_instance.gitlab-server.id
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

output "server_public_ip" {
  value       = aws_instance.gitlab-server.public_ip
  description = "Public IP of GitLab server"
}

output "server_hostname" {
  value = module.dns.hostname
}

output "server_private_ip" {
  value       = aws_instance.gitlab-server.private_ip
  description = "Private IP of GitLab server"
}

output "ci_public_ip" {
  value       = aws_instance.gitlab-ci.public_ip
  description = "Public IP of GitLab CI server"
}

output "ci_private_ip" {
  value       = aws_instance.gitlab-ci.private_ip
  description = "Private IP of GitLab CI server"
}

output "gitlab_ssh_private_key" {
  description = "Private SSH key for GitLab Server and CI runner"
  value       = module.ssh_key_pair.private_key_filename
}

output "gitlab_ssh_public_key" {
  description = "Public SSH key for GitLab Server and CI runner"
  value       = module.ssh_key_pair.public_key_filename
}

output "gitlab_root_pw" {
  description = "root pw for gitlab"
  value       = random_password.gitlab_root_password.result
  sensitive   = true
}

output "gitlab_root_token" {
  description = "root token for gitlab"
  value       = random_password.gitlab_root_token.result
  sensitive   = true
}