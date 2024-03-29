output "transit_gateway_arn" {
  value       = try(aws_ec2_transit_gateway.this[0].arn, "")
  description = "Transit Gateway ARN"
}

output "transit_gateway_id" {
  value       = try(aws_ec2_transit_gateway.this[0].id, "")
  description = "Transit Gateway ID"
}

output "transit_gateway_route_table_id" {
  value       = try(aws_ec2_transit_gateway_route_table.this[0].id, "")
  description = "Transit Gateway route table ID"
}

output "transit_gateway_association_default_route_table_id" {
  value       = try(aws_ec2_transit_gateway.this[0].association_default_route_table_id, "")
  description = "Transit Gateway association default route table ID"
}

output "transit_gateway_propagation_default_route_table_id" {
  value       = try(aws_ec2_transit_gateway.this[0].propagation_default_route_table_id, "")
  description = "Transit Gateway propagation default route table ID"
}

output "transit_gateway_vpc_attachment_ids" {
  value       = try({ for i, o in aws_ec2_transit_gateway_vpc_attachment.this : i => o["id"] }, {})
  description = "Transit Gateway VPC attachment IDs"
}

output "transit_gateway_route_ids" {
  value       = try({ for i, o in module.transit_gateway_route : i => o["transit_gateway_route_ids"] }, {})
  description = "Transit Gateway route identifiers combined with destinations"
}

output "subnet_route_ids" {
  value       = try({ for i, o in module.subnet_route : i => o["subnet_route_ids"] }, {})
  description = "Subnet route identifiers combined with destinations"
}

output "destination_cidr_blocks" {
  value       = try({ for i, o in module.subnet_route : i => o["destination_cidr_blocks"] }, {})
  description = "Destination CIDR blocks"
}

output "route_config_list" {
  value       = try({ for i, o in module.subnet_route : i => o["route_config_list"] }, {})
  description = "Route configuration list"
}

output "route_config_map" {
  value       = try({ for i, o in module.subnet_route : i => o["route_config_map"] }, {})
  description = "Route configuration map"
}

output "transit_gateway_route_config" {
  value       = try({ for i, o in module.transit_gateway_route : i => o["transit_gateway_route_config"] }, {})
  description = "Transit Gateway route configuration"
}
