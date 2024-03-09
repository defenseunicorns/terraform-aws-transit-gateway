output "transit_gateway_route_ids" {
  value       = values(aws_ec2_transit_gateway_route.default)[*].id
  description = "Transit Gateway route identifiers combined with destinations"
}

output "transit_gateway_route_config" {
  value       = local.route_config
  description = "Transit Gateway route configuration"
}
