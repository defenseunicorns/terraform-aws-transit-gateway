locals {
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      ManagedBy    = "Terraform"
      Repo         = "https://github.com/defenseunicorns/terraform-aws-transit-gateway"
    }
  )
}

resource "random_id" "this" {
  # if either of these are not set, generate a random suffix
  count = (
    (var.transit_gateway_name != null && var.transit_gateway_name != "") ||
    (var.transit_gateway_route_table_name != null && var.transit_gateway_route_table_name != "")
  ) ? 1 : 0
  byte_length = 8
}

locals {
  transit_gateway_id = var.existing_transit_gateway_id != null && var.existing_transit_gateway_id != "" ? var.existing_transit_gateway_id : (
    var.create_transit_gateway ? aws_ec2_transit_gateway.this[0].id : null
  )
  transit_gateway_route_table_id = var.existing_transit_gateway_route_table_id != null && var.existing_transit_gateway_route_table_id != "" ? var.existing_transit_gateway_route_table_id : (
    var.create_transit_gateway_route_table ? aws_ec2_transit_gateway_route_table.this[0].id : null
  )

  transit_gateway_name                       = var.transit_gateway_name != null && var.transit_gateway_name != "" ? var.transit_gateway_name : try("tgw-${random_id.this[0].hex}", "")
  transit_gateway_route_table_name           = var.transit_gateway_route_table_name != null && var.transit_gateway_route_table_name != "" ? var.transit_gateway_route_table_name : try("tgw-rt-${random_id.this[0].hex}", "")
  transit_gateway_vpc_attachment_name_prefix = lookup(data.aws_ec2_transit_gateway.this[0].tags, "Name", local.transit_gateway_name)

  # NOTE: This is the same logic as local.transit_gateway_id but we cannot reuse that local in the data source or
  # we get the dreaded error: "count" value depends on resource attributes
  lookup_transit_gateway = ((var.existing_transit_gateway_id != null && var.existing_transit_gateway_id != "") || var.create_transit_gateway)
}
resource "aws_ec2_transit_gateway" "this" {
  count                           = var.create_transit_gateway ? 1 : 0
  description                     = var.transit_gateway_description == "" ? "Transit Gateway" : var.transit_gateway_description
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks

  tags = merge(
    local.tags,
    {
      Name = local.transit_gateway_name
    }
  )
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  count              = var.create_transit_gateway_route_table ? 1 : 0
  transit_gateway_id = local.transit_gateway_id

  tags = merge(
    local.tags,
    {
      Name = local.transit_gateway_route_table_name
    }
  )
}

# Need to find out if VPC is in same account as Transit Gateway.
# See resource "aws_ec2_transit_gateway_vpc_attachment" below.
data "aws_ec2_transit_gateway" "this" {
  count = local.lookup_transit_gateway ? 1 : 0
  id    = local.transit_gateway_id
}

data "aws_vpc" "this" {
  for_each = var.create_transit_gateway_vpc_attachment && var.config != null ? var.config : {}
  id       = each.value["vpc_id"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each               = var.create_transit_gateway_vpc_attachment && var.config != null ? var.config : {}
  transit_gateway_id     = local.transit_gateway_id
  vpc_id                 = each.value["vpc_id"]
  subnet_ids             = each.value["subnet_ids"]
  appliance_mode_support = var.vpc_attachment_appliance_mode_support
  dns_support            = var.vpc_attachment_dns_support
  ipv6_support           = var.vpc_attachment_ipv6_support

  tags = merge(
    local.tags,
    {
      Name = join("_", compact([local.transit_gateway_vpc_attachment_name_prefix, coalesce(each.value["vpc_name"], each.value["vpc_id"])]))
    }
  )

  # transit_gateway_default_route_table_association and transit_gateway_default_route_table_propagation
  # must be set to `false` if the VPC is in the same account as the Transit Gateway, and `null` otherwise
  # https://github.com/terraform-providers/terraform-provider-aws/issues/13512
  # https://github.com/terraform-providers/terraform-provider-aws/issues/8383
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment
  transit_gateway_default_route_table_association = data.aws_ec2_transit_gateway.this[0].owner_id == data.aws_vpc.this[each.key].owner_id ? false : null
  transit_gateway_default_route_table_propagation = data.aws_ec2_transit_gateway.this[0].owner_id == data.aws_vpc.this[each.key].owner_id ? false : null
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each                       = var.create_transit_gateway_route_table_association && var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.this[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each                       = var.create_transit_gateway_propagation && var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.this[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.this[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
  route_config                   = each.value["static_routes"] != null ? each.value["static_routes"] : []

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this, aws_ec2_transit_gateway_route_table.this]
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route" {
  source                  = "./modules/subnet_route"
  for_each                = var.create_transit_gateway_vpc_attachment && var.config != null ? var.config : {}
  transit_gateway_id      = local.transit_gateway_id
  route_table_ids         = each.value["subnet_route_table_ids"] != null ? each.value["subnet_route_table_ids"] : []
  destination_cidr_blocks = each.value["route_to_cidr_blocks"] != null ? each.value["route_to_cidr_blocks"] : ([for i in setintersection(keys(var.config), (each.value["route_to"] != null ? each.value["route_to"] : [])) : var.config[i]["vpc_cidr"]])
  route_keys_enabled      = var.route_keys_enabled

  depends_on = [aws_ec2_transit_gateway.this, data.aws_ec2_transit_gateway.this, aws_ec2_transit_gateway_vpc_attachment.this]
}
