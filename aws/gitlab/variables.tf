variable "name" {
  description = "Name  (e.g. `gitlab`)"
  type        = string
  default     = "gitlab"
}

variable "namespace" {
  description = "Namespace. Used to help uniquely name resources"
  type        = string
}

variable "fqdn" {}

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
  default     = "t2.large"
  description = "Elastic cache instance type"
}

variable "gitlab_runner_size" {
  type        = string
  description = "Gitlab runner VM size"
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

variable "user_data" {
  type        = string
  default     = ""
  description = "User data content"
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

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "A list of CIDR blocks allowed to connect"

  default = [
    "0.0.0.0/0",
  ]
}

variable "user_data_file" {
  type        = string
  default     = "user_data.sh"
  description = "User data file"
}

variable "use_letsencrypt_staging" {
  type        = bool
  default     = false
  description = "use staging instead of prod letsencrypt endpoint"
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

variable "enable_github_oauth" {
  type = bool
  description = "enable auth from github oauth app"
  default = false
}

variable "github_oauth_id" {
  type        = string
  description = "github oauth id"
  default = ""
}

variable "github_oauth_secret" {
  type        = string
  description = "github oauth secret"
  default = ""
  sensitive = true
}

variable "smtp_server_enable" {
  type = bool
  description = "enable smtp"
  default = false
}

variable "smtp_server_address" {
  type        = string
  description = "smtp_server_address"
  default = ""
}

variable "smtp_server_port" {
  type        = number
  description = "smtp_server_port"
  default = 587
}

variable "smtp_server_user" {
  type        = string
  description = "smtp_server_user"
  default = ""
}

variable "smtp_server_pw" {
  type        = string
  description = "smtp_server_pw"
  default = ""
  sensitive = true
}

variable "smtp_server_mail_domain" {
  type        = string
  description = "smtp_server_mail_domain"
  default = ""
}

variable "gitlab_version" {
  type        = string
  description = "gitlab_version"
  default = "14.8.1-ee.0"
}