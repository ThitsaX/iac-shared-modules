
variable "iac_user_key_secret" {
  description = "iam user key secret"
}

variable "iac_user_key_id" {
  description = "iam user keyid"
}

variable "group_list" {
  description = "groups to pre-create"
}

variable "env_list" {
  description = "env repos to pre-create"
}

variable "root_token" {
  description = "root_token"
}

variable "gitlab_url" {
  description = "gitlab_url"
}

variable "two_factor_grace_period" {
  description = "two_factor_grace_period in hours"
  default = 0
}

variable "remote_state_bucket" {
  description = "remote_state bucket name"
}

variable "remote_state_table" {
  description = "remote_state table name"
}