variable "extgw_admin_port" {
  description = "Port number for External GW admin service"
  type        = number
  default     = 9443
}

variable "extgw_token_service_port" {
  description = "Port number for External GW token service"
  type        = number
  default     = 8243
}

variable "extgw_fqdn" {
  description = "FQDN of Internal GW service"
  type        = string
}

variable "admin_user" {
  description = "Username to use when configuring WSO2"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Passwrod to use when configuring WSO2"
  type        = string
  default     = "admin"
}

variable "test_user_details" {
  description = "map of user details"
  type        = map
}

variable "extgw_state" {
  description = "State of External GW Helm deployment"
  type        = string
  default     = "notused"
}
