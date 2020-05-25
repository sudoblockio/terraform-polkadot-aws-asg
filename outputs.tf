output "name" {
  value = local.name
}

output "id" {
  value = local.id
}

output "tags" {
  value = var.tags
}

output "user_data" {
  value = module.user_data.user_data
}

output "autoscaling_group_arn" {
  value = module.asg.this_autoscaling_group_arn
}

output "autoscaling_group_id" {
  value = module.asg.this_autoscaling_group_id
}

output "autoscaling_group_name" {
  value = module.asg.this_autoscaling_group_name
}

output "public_ips" {
  value = aws_eip.this.*.public_ip
}

output "dns_name" {
  value = aws_lb.this[0].dns_name
}

output "lb_id" {
  value = aws_lb.this[0].id
}

output "lb_arn" {
  value = aws_lb.this[0].arn
}

output "lb_rpc_target_group_arn" {
  value = aws_lb_target_group.rpc[0].arn
}

output "lb_rpc_target_group_id" {
  value = aws_lb_target_group.rpc[0].id
}

output "lb_wss_target_group_arn" {
  value = aws_lb_target_group.wss[0].arn
}

output "lb_wss_target_group_id" {
  value = aws_lb_target_group.wss[0].id
}