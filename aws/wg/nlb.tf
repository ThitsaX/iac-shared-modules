resource "aws_route53_record" "wireguard-dns" {
  zone_id = var.zone_id
  name    = "wireguard.${var.cert_domain}"
  type    = "A"
  alias {
    name                   = aws_alb.nlb.dns_name
    zone_id                = aws_alb.nlb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_eip" "nlb" {
  tags = merge(
    var.tags,
    {
      "Name" = "eip-wireguard"
    }
  )
}

resource "aws_acm_certificate" "wireguard-cert" {
  domain_name       = aws_route53_record.wireguard-dns.fqdn
  validation_method = "DNS"

  tags = merge(
    var.tags,
    {
      "Name" = "acm-cert-wireguard"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.wireguard-cert.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.wireguard-cert.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.wireguard-cert.domain_validation_options)[0].resource_record_type
  zone_id  = var.zone_id
  ttl      = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.wireguard-cert.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation.fqdn ]
}

resource "aws_lb" "nlb" {
  name               = "nlb-wireguard"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id     = var.subnet_id
    allocation_id = aws_eip.nlb.id
  }

  tags = merge(
    var.tags,
    {
      "Name" = "nlb-wireguard"
    }
  )
}

resource "aws_lb_listener" "nlb" {

  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.wireguard-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wireguard-5000.arn
  }
  tags = merge(
    var.tags,
    {
      "Name" = "nlb-wireguard"
    }
  )

}

resource "aws_lb_listener" "port_51820" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "51820"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wireguard-51820.arn
  }
  tags = merge(
    var.tags,
    {
      "Name" = "nlb-wireguard"
    }
  )
}

resource "aws_lb_target_group" "wireguard-51820" {
  port     = 51820
  protocol = "UDP"
  vpc_id   = module.vpc.vpc_id

  # TODO: can't health check against a UDP port, but need to have a health check when backend is an instance. 
  # check tcp port 5000 (ui) for now

    protocol = "TCP"
    port     = 5000
  }

  tags = merge(
    var.tags,
    {
      "Name" = "nlb-wireguard"
    }
  )
}

resource "aws_lb_target_group" "wireguard-5000" {
  
  port                 = 5000
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 90

  health_check {
    interval            = 10
    port                = 5000
    protocol             = "TCP"
    healthy_threshold    = 3
    unhealthy_threshold  = 3
  }

  tags = merge(
    var.tags,
    {
      "Name" = "nlb-tgr-wireguard-5000"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "wg-attachment" { 
  target_group_arn = aws_lb_target_group.wireguard-5000.arn
  target_id        = aws_instance.wireguard.id
}
resource "aws_lb_target_group_attachment" "wg-attachment" { 
  target_group_arn = aws_lb_target_group.wireguard-51820.arn
  target_id        = aws_instance.wireguard.id
}