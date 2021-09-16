variable "ami_id" {
  description = "Id of Amazon Image to use"
  type = string
}

variable "instance_type" {
  description = "Size of the EC2 instance"
  type = string
}

variable "ssh_key_name" {
  description = "SSH key name used to provision this server"
  type = string
}

variable "security_groups" {
  description = "security groups attached to this server"
}

variable "subnet_id" {
  description = "Id of the subnet used by this instance"
}

variable "vpc_id" {
  description = "Id of the vpc used by this instance"
}

variable "tags" {
  description = "Any additional tags that we might want to pass on"
  default     = { Name = "Wireguard" }
}

variable "ssh_key" {
  description = "private key used to access this server"
}

variable "ui_admin_pw" {
  description = "admin pw for ui"
}

variable "cert_domain" {
  description = "domain for cert for tls offloading"
}