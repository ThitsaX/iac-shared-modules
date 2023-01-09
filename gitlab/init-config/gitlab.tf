resource "gitlab_group" "rbac-groups" {
  for_each = toset(var.group_list)
  name        = each.value
  path        = each.value
  description = "${each.value} group"
}

resource "gitlab_group" "iac" {
  name        = "iac"
  path        = "iac"
  description = "iac group"
  require_two_factor_authentication = true
  two_factor_grace_period = var.two_factor_grace_period
}

resource "gitlab_group_variable" "iam_user_key_id" {
  group             = gitlab_group.iac.id
  key               = "AWS_ACCESS_KEY_ID"
  value             = var.iac_user_key_id
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "iam_user_key_secret" {
  group             = gitlab_group.iac.id
  key               = "AWS_SECRET_ACCESS_KEY"
  value             = var.iac_user_key_secret
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "remote_state_table" {
  group             = gitlab_group.iac.id
  key               = "REMOTE_STATE_TABLE"
  value             = var.remote_state_table
  protected         = false
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "remote_state_bucket" {
  group             = gitlab_group.iac.id
  key               = "REMOTE_STATE_BUCKET"
  value             = var.remote_state_bucket
  protected         = false
  masked            = false
  environment_scope = "*"
}

resource "gitlab_project" "envs" {
  for_each = toset(var.env_list)
  name = each.value
  namespace_id = gitlab_group.iac.id
  initialize_with_readme = true
  shared_runners_enabled = true
}

resource "gitlab_project" "bootstrap" {
  name = "bootstrap"
  namespace_id = gitlab_group.iac.id
  initialize_with_readme = true
  shared_runners_enabled = false
}