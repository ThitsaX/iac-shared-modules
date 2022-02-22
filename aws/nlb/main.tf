resource "aws_eip" "nlb" {
  count = var.internal_lb ? 0 : 1
  tags = merge(
    var.tags,
    {
      "Name" = "eip-${var.prefix}"
    }
  )
}

resource "aws_lb" "nlb" {
  name               = "nlb-${var.prefix}"
  load_balancer_type = "network"
  internal           = var.internal_lb
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  subnet_mapping {
    subnet_id     = var.subnet_id
    allocation_id = var.internal_lb ? null : aws_eip.nlb[0].id
  }

  tags = merge(
    var.tags,
    {
      "Name" = "nlb-${var.prefix}"
    }
  )
}

resource "aws_lb_listener" "nlb" {
  for_each = {
    for l in var.nlb_listeners : "${l.protocol}:${l.target_port}" => l
  }

  load_balancer_arn = aws_lb.nlb.arn
  port              = each.value.listen_port != "" ? each.value.listen_port : each.value.target_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb["${each.value.protocol}:${each.value.target_port}"].arn
  }

}

resource "aws_lb_target_group" "nlb" {
  for_each = {
    for l in var.nlb_listeners : "${l.protocol}:${l.target_port}" => l
  }

  port                 = each.value.target_port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = each.value.deregistration_delay
  preserve_client_ip = var.preserve_client_ip
  proxy_protocol_v2 = var.proxy_protocol

  health_check {
    interval            = each.value.interval
    port                = each.value.health_port
    protocol            = each.value.protocol
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
  }

  tags = merge(
    var.tags,
    {
      "Name" = "nlb-tgr-${var.prefix}-${each.value.target_port}"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  tg_keys = [for l in var.nlb_listeners : "${l.protocol}:${l.target_port}"]
}

resource "aws_lb_target_group_attachment" "attachment" {
  count = length(var.nlb_listeners) * length(var.instance_ids)

  target_group_arn = aws_lb_target_group.nlb[element(local.tg_keys, count.index)].arn
  target_id        = element(var.instance_ids, count.index)
}
