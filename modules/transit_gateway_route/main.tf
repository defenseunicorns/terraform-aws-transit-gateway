locals {
  route_config = {
    # change this to a join
    for rc in var.route_config : join("_", compact([
      rc.destination_cidr_block,
      "bh_${tostring(rc.blackhole)}"])
      ) => {
      destination_cidr_block              = rc.destination_cidr_block,
      route_transit_gateway_attachment_id = rc.route_transit_gateway_attachment_id != null && rc.route_transit_gateway_attachment_id != "" ? rc.route_transit_gateway_attachment_id : (rc.blackhole ? null : var.vpc_transit_gateway_attachment_id),
      blackhole                           = rc.blackhole
    }
  }
}

resource "aws_ec2_transit_gateway_route" "default" {
  for_each                       = local.route_config
  blackhole                      = each.value.blackhole
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_route_table_id = var.transit_gateway_route_table_id

  transit_gateway_attachment_id = each.value.blackhole ? null : each.value.route_transit_gateway_attachment_id
}
