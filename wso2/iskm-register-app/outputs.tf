output "consumer-key" {
  description = "Client ID / Consumer Key for oAuth/OIDC usage"
  value = data.external.get_secret_and_key.result["consumerKey"]
}
output "consumer-secret" {
  description = "Client / Consumer secret for oAuth/OIDC usage"
  value = data.external.get_secret_and_key.result["oauthConsumerSecret"]
}