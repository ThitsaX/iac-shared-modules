variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "AWS subnet ID"
  type        = string
}

variable "name" {
  type = string
}

variable "key_pair_name" {
  description = "SSH Key name"
  type        = string
}

variable "environment" {
  description = "Name of environment this SDK belongs to"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "AWS Instance type"
  type        = string
  default     = "t2.medium"
}

variable "extra_sgs" {
  description = "List of AWS security group IDs"
  type        = list(string)
  default     = []
}

variable "extra_packages" {
  description = "List - as a string - of Ubuntu packages to install in EC2 instances"
  type        = string
}

variable "external_nameserver" {
  description = "Nameserver resolver to add to /etc/resolv.conf"
  type        = string
}

variable "template_filename" {
  description = "User data file template"
  type        = string
  default     = "user_data.sh.tpl"
}

variable "ami" {
  description = "AMI to use"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "domain" {
  description = "Domain name to create DNS entries"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
