resource "aws_autoscaling_policy" "this" {
  name            = "${local.name}-scaling"
  adjustment_type = "ChangeInCapacity"
  policy_type     = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80
  }

  autoscaling_group_name = module.asg.this_autoscaling_group_name
}