variable "intgw_fqdn" {
  description = "FQDN of Internal GW service"
  type        = string
}

variable "intgw_rest_port" {
  description = "Port number for Interal GW ReST service"
  type        = number
  default     = 9843
}

variable "intgw_token_port" {
  description = "Port number for Interal GW Token service"
  type        = number
  default     = 8843
}

variable "environment" {
  description = "WSO2 environment name"
  type        = string
  default     = "mojaloop"
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

variable "test_user_details" {
  description = "map of test account details"
  type        = map
}

variable "intgw_state" {
  description = "State of Internal GW Helm deployment"
  type        = string
  default     = "notused"
}

variable "fspiop_version" {
  description = "Version of fspiop to use"
  type        = string
  default     = "1.1"
}
