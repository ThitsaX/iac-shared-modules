
output "client-ids" {
  description = "key for test user usage"
  value = {
    for instance in keys(null_resource.create_artifacts_return_credentials) :
    "${instance}" => jsondecode(fileexists("${instance}_results") ? file("${instance}_results") : "{\"clientId\":\"notinitialized\", \"id\":\"${lookup(null_resource.create_artifacts_return_credentials, instance).id}\"}")["clientId"]
  }

  depends_on = [null_resource.create_artifacts_return_credentials]
}
output "client-secrets" {
  description = "secret for test user usage"
  value = {
    for instance in keys(null_resource.create_artifacts_return_credentials) :
    "${instance}" => jsondecode(fileexists("${instance}_results") ? file("${instance}_results") : "{\"clientSecret\":\"notinitialized\",\"id\":\"${lookup(null_resource.create_artifacts_return_credentials, instance).id}\"}")["clientSecret"]
  }

  depends_on = [null_resource.create_artifacts_return_credentials]
}
output "client-basic-auth-headers" {
  description = "auth header for test user usage"
  value = {
    for instance in keys(null_resource.create_artifacts_return_credentials) :
    "${instance}" => jsondecode(fileexists("${instance}_results") ? file("${instance}_results") : "{\"basicAuthHeader\":\"notinitialized\",\"id\":\"${lookup(null_resource.create_artifacts_return_credentials, instance).id}\"}")["basicAuthHeader"]
  }

  depends_on = [null_resource.create_artifacts_return_credentials]
}
