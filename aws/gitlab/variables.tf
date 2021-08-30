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
  type        = boolean
  detault     = false
  description = "use staging instead of prod letsencrypt endpoint"
}