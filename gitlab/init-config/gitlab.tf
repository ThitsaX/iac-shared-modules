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
}

resource "gitlab_group_variable" "iam_user_key_id" {
  group             = gitlab_group.iac
  key               = "AWS_ACCESS_KEY_ID"
  value             = var.iac_user_key_id
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_group_variable" "iam_user_key_secret" {
  group             = gitlab_group.iac
  key               = "AWS_SECRET_ACCESS_KEY"
  value             = var.iac_user_key_secret
  protected         = true
  masked            = false
  environment_scope = "*"
}

resource "gitlab_project" "envs" {
  for_each = toset(var.env_list)
  name = each.value
  namespace_id = gitlab_group.iac.id
  initialize_with_readme = true
}