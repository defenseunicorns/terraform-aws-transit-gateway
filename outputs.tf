output "transit_gateway_arn" {
  value       = try(module.transit_gateway.arn, "")
  description = "Transit Gateway ARN"
}

output "transit_gateway_id" {
  value       = try(module.transit_gateway.transit_gateway_id, "")
  description = "Transit Gateway ID"
}

output "transit_gateway_route_table_id" {
  value       = try(module.transit_gateway.transit_gateway_route_table_id, "")
  description = "Transit Gateway route table ID"
}
