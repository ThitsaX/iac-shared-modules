resource "aws_eip" "nlb" {
  tags = merge(
    var.tags,
    {
      "Name" = "eip-wireguard"
    }
  )
}

resource "aws_acm_certificate" "wireguard-cert" {
  domain_name       = var.cert_domain
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
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.wireguard-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wireguard-5000.arn
  }

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
