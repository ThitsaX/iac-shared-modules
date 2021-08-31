variable "iskm_rest_port" {
  description = "Port number for External GW ReST service"
  type        = number
  default     = 9443
}

variable "iskm_fqdn" {
  description = "FQDN of Internal GW service"
  type        = string
}


variable "create_service_provider" {
  description = "Whether or not to create service provider `y`"
  type        = string
  default     = "y"
}

variable "user" {
  description = "Username to use when configuring WSO2"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Passwrod to use when configuring WSO2"
  type        = string
  default     = "admin"
}

variable "iskm_status" {
  description = "iskm install status"
  type        = string
  default     = "notused"

}

