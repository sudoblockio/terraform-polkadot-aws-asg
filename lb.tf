##########
# Load Balancer
##########

variable "use_lb" {
  description = "Bool to enable use of load balancer"
  type        = bool
  default     = true
}

resource "aws_eip" "this" {
  count = var.use_lb ? length(local.subnet_ids) : 0
  tags  = merge(var.tags, { Name = "${var.name}-1" })
}

# Network Load Balancer for apiservers and ingress
resource "aws_lb" "this" {
  count = var.use_lb ? 1 : 0
  name  = local.id

  load_balancer_type = "network"

  internal = false

  dynamic "subnet_mapping" {
    for_each = local.subnet_ids

    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.this.*.id[subnet_mapping.key]
    }
  }

  enable_cross_zone_load_balancing = true

  depends_on = [aws_eip.this]
}

resource "aws_lb_listener" "rpc" {
  for_each          = var.use_lb ? local.network_settings : {}
  load_balancer_arn = aws_lb.this[0].arn
  protocol          = "TCP"
  port              = each.value["json_rpc"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rpc[each.key].arn
  }
}

resource "aws_lb_listener" "wss" {
  for_each          = var.use_lb ? local.network_settings : {}
  load_balancer_arn = aws_lb.this[0].arn
  protocol          = "TCP"
  port              = each.value["ws_rpc"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wss[each.key].arn
  }
}

resource "aws_lb_listener" "ext-health" {
  for_each          = var.use_lb ? local.network_settings : {}
  load_balancer_arn = aws_lb.this[0].arn
  protocol          = "TCP"
  port              = each.value["api_health"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext-health[each.key].arn
  }
}

resource "aws_lb_target_group" "rpc" {
  for_each    = var.use_lb ? local.network_settings : {}
  name        = "${local.id}-${each.value["name"]}-rpc"
  vpc_id      = local.vpc_id
  target_type = "instance"

  protocol = "TCP"
  port     = each.value["json_rpc"]

  health_check {
    protocol = "TCP"
    port     = each.value["api_health"]

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Interval between health checks required to be 10 or 30
    interval = 10
  }
  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_target_group" "wss" {
  for_each    = var.use_lb ? local.network_settings : {}
  name        = "${local.id}-${each.value["name"]}-wss"
  vpc_id      = local.vpc_id
  target_type = "instance"

  protocol = "TCP"
  port     = each.value["ws_rpc"]

  health_check {
    protocol = "TCP"
    port     = each.value["api_health"]

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Interval between health checks required to be 10 or 30
    interval = 10
  }
  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_target_group" "ext-health" {
  for_each    = var.use_lb ? local.network_settings : {}
  name        = "${local.id}-${each.value["name"]}-hc"
  vpc_id      = local.vpc_id
  target_type = "instance"

  protocol = "TCP"
  port     = each.value["api_health"]

  tags = merge(var.tags, { Name = var.name })
}
