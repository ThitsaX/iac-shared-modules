output "mcm-key" {
  description = "key for mcm usage"
  value       = jsondecode(fileexists("iskm_result") ? file("iskm_result") : "{\"consumerKey\":\"invalid\"}")["consumerKey"]
}

output "mcm-secret" {
  description = "secret for mcm usage"
  value       = jsondecode(fileexists("iskm_result") ? file("iskm_result") : "{\"oauthConsumerSecret\":\"invalid\"}")["oauthConsumerSecret"]
}
