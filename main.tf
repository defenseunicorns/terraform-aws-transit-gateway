
# Query the main route table for the transit gateway
data "aws_ec2_transit_gateway_route_table" "route_table" {
  filter {
    name   = "tag:Name"
    values = [var.target_transit_gateway_tag_name]
  }
}

# Create a TGW attachment to attach the VPC to the existing TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = try(data.aws_ec2_transit_gateway_route_table.route_table.transit_gateway_id, "")
  vpc_id             = var.vpc_id
  tags = merge(
    {
      "Name" = var.vpc_id,
    },
    var.tags
  )
}

# route all VPC traffic to the TGW
resource "aws_route" "route_to_tgw_rtb_for_this_vpc" {
  route_table_id         = var.vpc_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = try(data.aws_ec2_transit_gateway_route_table.route_table.transit_gateway_id, "")
}

# Create a new route table to be used for VPC egress
resource "aws_ec2_transit_gateway_route_table" "transit_gateway_route_table_for_vpc_egress" {
  transit_gateway_id = try(data.aws_ec2_transit_gateway_route_table.route_table.transit_gateway_id, "")
  tags = merge(
    {
      "Name" = "${var.vpc_id}-TGW-RTB",
    },
    var.tags
  )
}

# Create a route table association to the transit gateway for the VPC attachment
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_for_vpc_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table_for_vpc_egress.id
}

# Feed in a vpc attachment id and the cidr of the route to create; get transit gateway id from main transit gateway route table
resource "aws_ec2_transit_gateway_route" "route" {
  for_each                       = var.routes_config
  destination_cidr_block         = each.value["route_to_cidr_block"]
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit_gateway_route_table_for_vpc_egress.transit_gateway_id
  transit_gateway_attachment_id  = each.value["attachment_id"]
}

data "aws_ec2_transit_gateway_peering_attachment" "peering_attachment" {
  filter {
    name   = "Name"
    values =  [ var.target_transit_gateway_tag_name ]
  
  }
}

# Feed in static routes for main route table used with peering attachment
resource "aws_ec2_transit_gateway_route" "route" {
  for_each                       = var.routes_config
  destination_cidr_block         = each.value["route_to_cidr_block"]
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.route_table.transit_gateway_id
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.peering_attachment.id
} 

# TODO - figure out route propagation
# Feed in static routes for main route table used with the attachment of the other transit gateway peering
resource "aws_ec2_transit_gateway_route" "route" {
  for_each                       = var.routes_config
  destination_cidr_block         = each.value["route_to_cidr_block"]
  # TODO - figure out how to query for peered_route_table_id that may exist in a separate account
  transit_gateway_route_table_id = length(var.peered_route_table_id) > 0 ? var.peered_route_table_id : "TBD"
  transit_gateway_attachment_id  = length(var.peered_attachment_id) > 0 ? var.peered_attachment_id : data.aws_ec2_transit_gateway_peering_attachment.peering_attachment.peer_transit_gateway_id
} 
