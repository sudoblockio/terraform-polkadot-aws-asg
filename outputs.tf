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
