output "mcm-key" {
  description = "key for mcm usage"
  value = data.external.get_secret_and_key.result["consumerKey"]
}
output "mcm-secret" {
  description = "secret for mcm usage"
  value = data.external.get_secret_and_key.result["oauthConsumerSecret"]
}