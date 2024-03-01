module "transit_gateway_a" {
  source                                                         = "cloudposse/transit-gateway/aws"
  version                                                        = "0.11.0"
  config                                                         = null
  tags                                                           = { Name = "transit-gateway-a" }
  create_transit_gateway                                         = true
  create_transit_gateway_route_table                             = true
  create_transit_gateway_route_table_association_and_propagation = false
  create_transit_gateway_vpc_attachment                          = false
  default_route_table_association                                = "disable"
  default_route_table_propagation                                = "disable"
  ram_resource_share_enabled                                     = false
}

module "transit_gateway_b" {
  source                                                         = "cloudposse/transit-gateway/aws"
  version                                                        = "0.11.0"
  config                                                         = null
  tags                                                           = { Name = "transit-gateway-b" }
  create_transit_gateway                                         = true
  create_transit_gateway_route_table                             = true
  create_transit_gateway_route_table_association_and_propagation = false
  create_transit_gateway_vpc_attachment                          = false
  default_route_table_association                                = "disable"
  default_route_table_propagation                                = "disable"
  ram_resource_share_enabled                                     = false
}

## NOTE: The peering attachment request has to be manually accepted as a separate step
resource "aws_ec2_transit_gateway_peering_attachment" "peering_attachment_transit_gateway_a_to_b" {
  peer_region             = var.region
  transit_gateway_id      = module.transit_gateway_a.transit_gateway_id
  peer_transit_gateway_id = module.transit_gateway_b.transit_gateway_id
}

# TODO - validate create peering attachment acceptor
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "accept_peering_attachment_transit_gateway_a_to_b" {
  transit_gateway_attachment_id = module.transit_gateway_b.transit_gateway_id

  tags = {
    Name = "Example for accepting a peering attachment (in the same account - not cross-account)"
  }
}