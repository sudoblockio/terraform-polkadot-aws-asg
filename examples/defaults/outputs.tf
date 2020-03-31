output "tags" {
  value = module.defaults.tags
}

output "name" {
  value = module.defaults.name
}

output "public_ips" {
  value = module.lb.public_ips
}

output "dns_name" {
  value = module.lb.dns_name
}