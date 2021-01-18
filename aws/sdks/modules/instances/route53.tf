data "aws_route53_zone" "selected" {
  name = var.domain
}

resource "aws_route53_record" "instance_dns" {
  count   = var.instance_count
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.name}-${count.index}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.app_server.*.public_ip, count.index)]
}
