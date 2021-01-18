variable "region" {
  description = "AWS region. Changing it will lead to loss of complete stack."
  type        = string
}

variable "tenant" {
  description = "Name of the tenant"
  type        = string
}

variable "environment" {
  description = "Name of environment this SDK belongs to"
  type        = string
  default     = "dev"
}

variable "ami" {
  description = "AWS Instance type"
  type        = string
  default     = "ami-06fd8a495a537da8b" # Ubuntu 20.04 LTS in eu-west-1
}

variable "k3s_ami" {
  description = "AWS Instance type"
  type        = string
  default     = "ami-06fd8a495a537da8b" # Ubuntu 20.04 LTS in eu-west-1
}

variable "domain" {
  description = "Domain name to create DNS entries"
  type        = string
}

variable "sdks" {
  description = "A list of maps Mock FSP data."
  type        = list(map(string))
  # Sample data: 
  #default = [
  #  { "name" : "emoments", "port" : "4000", "instance" : "0", "currency" : "UGX", "msisdn" : "256111111111", "business_id" : "emomentsMerchant", "notification_email" : "test@modusbox.com" },
  #  { "name" : "yougandaltd", "port" : "4100", "instance" : "0", "currency" : "UGX", "msisdn" : "256222222222", "business_id" : "yougantaltdMerchant", "notification_email" : "test@modusbox.com" }
  #]
  # name - The name of the dfsp
  # port - The port which the dfsp will listen on
  # instance - Index of the VM instance which this dfsp will be deployed on
  # current, msisdn, business_id, notification_email - DFSP configuration which is exported as part of output, to be consumed externally when provisioning."
}

variable "client_node_count" {
  description = "Number of client nodes to create with docker-compose"
  type        = number
  default     = 1
}

variable "k3s_node_count" {
  description = "Number of k3s nodes to create"
  type        = number
  default     = 0
}

variable "allow_ssh_access" {
  description = "CIDR block that can access instances via SSH"
  default     = ["0.0.0.0/0"] # Wireguard public IP
}

variable "allow_cbs_access" {
  description = "List of CIDR blocks that can access cbs ports"
  default = [
    "0.0.0.0/0"
  ]
}

variable "allow_sdk_access" {
  description = "List of CIDR blocks that can access sdk ports"
  default = [
    "0.0.0.0/0"
  ]
}

variable "allow_k3s_access" {
  description = "List of CIDR blocks that can access k3s kubeapi"
  default     = ["10.0.0.0/16"]
}

variable "vpc_cidr" {
  description = "CIDR block to allocate the SDK VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for public and private subnets"
  type        = map(string)
  default = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
}

variable "external_nameserver" {
  description = "DNS resolver address"
  type        = string
  default     = "8.8.8.8"
}

variable "extra_packages" {
  description = "Additional packages to install for particular module"
  type        = map(string)
  default = {
    sdk = "wget bind-utils docker nc git"
  }
}
