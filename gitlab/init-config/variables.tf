
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