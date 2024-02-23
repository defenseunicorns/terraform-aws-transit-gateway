module "transit_gateway" {
  source  = "cloudposse/transit-gateway/aws"
  version = "0.11.0"

  config                                                         = var.config
  tags                                                           = var.tgw_tags
  create_transit_gateway                                         = var.create_transit_gateway
  create_transit_gateway_route_table                             = var.create_transit_gateway_route_table
  create_transit_gateway_route_table_association_and_propagation = var.create_transit_gateway_route_table_association_and_propagation
  create_transit_gateway_vpc_attachment                          = var.create_transit_gateway_vpc_attachment
  default_route_table_association                                = var.default_route_table_association
  default_route_table_propagation                                = var.default_route_table_propagation

  existing_transit_gateway_id             = var.existing_transit_gateway_id
  existing_transit_gateway_route_table_id = var.existing_transit_gateway_route_table_id

  ram_resource_share_enabled = var.ram_resource_share_enabled
  ram_principals             = var.ram_principals

}
