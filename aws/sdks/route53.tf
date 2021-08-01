data "aws_route53_zone" "selected" {
  name = var.domain
}

resource "aws_route53_record" "fsp_dns" {
  for_each = { for obj in var.sdks : obj.name => obj.instance }
  zone_id  = data.aws_route53_zone.selected.zone_id
  name     = each.key
  type     = "A"
  ttl      = "300"
  records  = [element(module.clientnode.publicIPs, each.value)]
}
