variable "name" {
  description = "Name  (e.g. `app` or `bastion`)"
  type        = string
  default     = "netmaker"
}

variable "namespace" {
  description = "Namespace. Used to help uniquely name resources"
  type        = string
}

variable "domain" {
  description = "Base domain"
  type        = string
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 DNS Zone ID"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Elastic cache instance type"
}

variable "ami" {
  type        = string
  default     = "ami-0e219142c0bee4a6e"
  description = "AMI to use"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnets" {
  type        = list(string)
  description = "AWS subnet IDs"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "Key name"
}

variable "ssh_user" {
  type        = string
  description = "Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems"
  default     = "ubuntu"
}

variable "security_groups" {
  type        = list(string)
  description = "AWS security group IDs"
}

variable "netmaker_admin_password" {
  type        = string
  description = "netmaker admin password, if blank, random pw will be generated"
  default = ""
}

variable "delete_storage_on_term" {
  type        = bool
  description = "should storage be deleted on term"
  default = true
}

variable "tenant" {
  type        = string
  description = "tenancy name"
}

variable "number_wg_networks" {
  type        = number
  description = "number of extra wg networks"
  default = 0
}

variable "server_public_ip" {
  type        = string
  description = "public ip for server"
}

variable "letsencrypt_email" {
  type        = string
  description = "email for letsencrypt notifications"
}