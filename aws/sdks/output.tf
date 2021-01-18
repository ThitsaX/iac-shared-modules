output "publicIPs" {
  description = "List of nodes public IPs, json encoded"
  value       = jsonencode(flatten([module.clientnode.publicIPs, module.k3snode.publicIPs]))
}

output "hosts" {
  description = "List of nodes hostnames, json encoded"
  value       = jsonencode(flatten([module.clientnode.hosts, module.k3snode.hosts]))
}

#"currency": "UGX", "msisdn" : "256111111111", "business_id": "emomentsMerchant", "notification_email":
locals {
  dfsp_data = [for obj in var.sdks : { "name" = obj.name,
    "fqdn"               = aws_route53_record.fsp_dns[obj.name].fqdn,
    "endpoint"           = "${aws_route53_record.fsp_dns[obj.name].fqdn}:${obj.port}"
    "currency"           = obj.currency,
    "msisdn"             = obj.msisdn,
    "business_id"        = obj.business_id,
    "notification_email" = obj.notification_email,
    "account_id"         = obj.account_id,
    "sim_endpoint"       = "${aws_route53_record.fsp_dns[obj.name].fqdn}:${obj.sim_port}"
  }]
}

output "dfsp_data" {
  description = "JSON object describing the dfsps and their endpoints"
  value       = jsonencode(local.dfsp_data)
}

output "domain" {
  description = "Base domain into which the VMs and dfsps are created"
  value       = var.domain
}
