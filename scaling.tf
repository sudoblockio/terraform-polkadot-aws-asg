variable "enable_scaling" {
  description = "Bool to enable scaling policy"
  type        = bool
  default     = true
}

variable "scaling_cpu_utilization" {
  description = "The percent CPU utilization for scaling."
  type        = number
  default     = 80
}

variable "instance_warmup_time" {
  description = "The time in seconds the instance is estimated to require to warm up"
  type        = number
  default     = 9000
}

resource "aws_autoscaling_policy" "this" {
  count                     = var.enable_scaling ? 1 : 0
  name                      = "${local.name}-scaling"
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = var.instance_warmup_time

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.scaling_cpu_utilization
  }

  autoscaling_group_name = module.asg.autoscaling_group_name
}