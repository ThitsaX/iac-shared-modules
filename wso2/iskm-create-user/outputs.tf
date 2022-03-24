output "account_userid" {
  description = "UserID of the user"
  value = data.external.create_user.result["account_userid"]
}
output "user_created" {
  description = "User is created or not"
  value = data.external.create_user.result["user_created"]
}
output "user_modified" {
  description = "User is modified or not"
  value = data.external.create_user.result["user_modified"]
}