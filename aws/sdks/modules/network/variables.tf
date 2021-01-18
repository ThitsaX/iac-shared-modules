variable "allow_ssh_access" {
  description = "List of CIDR blocks that can access instances via SSH"
  type        = list(string)
  default     = []
}

variable "allow_sdk_access" {
  description = "List of CIDR blocks that can access SDK ports"
  type        = list(string)
  default     = []
}

variable "allow_cbs_access" {
  description = "List of CIDR blocks that can access CBS ports"
  type        = list(string)
  default     = []
}

variable "allow_k3s_access" {
  description = "List of CIDR blocks that can access k3s kubeapi"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "VPC ID"
  type        = string
}

variable "subnet_cidrs" {
  description = "CIDR blocks for public and private subnets"
  type        = map(string)
  default     = {}
}
