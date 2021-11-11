variable "iskm_fqdn" {
  description = "FQDN of WSO2 service"
  type        = string
}

variable "iskm_admin_port" {
  description = "Port number for WSO2 admin service"
  type        = number
  default     = 9443
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

variable "account_username" {
  description = "Username of the new account"
  type        = string
}

variable "account_password" {
  description = "Password for the new account"
  type        = string
}

variable "account_email" {
  description = "Email address to set for the new account"
  type        = string
}
