output "subnet_route_ids" {
  value       = compact(concat(values(aws_route.keys)[*].id))
  description = "Subnet route identifiers combined with destinations"
}

output "destrination_cidr_blocks" {
  value       = var.destination_cidr_blocks
  description = "Destination CIDR blocks"
}

output "route_config_list" {
  value       = local.route_config_list
  description = "Route configuration list"
}

output "route_config_map" {
  value       = local.route_config_map
  description = "Route configuration map"
}
