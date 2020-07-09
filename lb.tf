resource "aws_eip" "this" {
  count = var.use_lb ? length(var.subnet_ids) : 0
}

# Network Load Balancer for apiservers and ingress
resource "aws_lb" "this" {
  count = var.use_lb ? 1 : 0
  name  = local.id

  load_balancer_type = "network"

  internal = false

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids

    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.this.*.id[subnet_mapping.key]
    }
  }

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "rpc" {
  count             = var.use_lb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  protocol          = "TCP"
  port              = 9933

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rpc[0].arn
  }
}

resource "aws_lb_listener" "wss" {
  count             = var.use_lb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  protocol          = "TCP"
  port              = 9944

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wss[0].arn
  }
}

resource "aws_lb_target_group" "rpc" {
  count       = var.use_lb ? 1 : 0
  name        = "${local.id}-rpc"
  vpc_id      = var.vpc_id
  target_type = "instance"

  protocol = "TCP"
  port     = 9933

  health_check {
    protocol = "TCP"
    port     = 5500

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Interval between health checks required to be 10 or 30
    interval = 10
  }
}

resource "aws_lb_target_group" "wss" {
  count       = var.use_lb ? 1 : 0
  name        = "${local.id}-wss"
  vpc_id      = var.vpc_id
  target_type = "instance"

  protocol = "TCP"
  port     = 9944

  health_check {
    protocol = "TCP"
    port     = 5500

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Interval between health checks required to be 10 or 30
    interval = 10
  }
}
