provider "aws" {
  region = var.region
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}


data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "random_id" "default" {
  byte_length = 2
}

locals {
  azs      = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
  vpc_name = "${var.name_prefix}-${lower(random_id.default.hex)}"
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      ManagedBy    = "Terraform"
      Repo         = "https://github.com/defenseunicorns/terraform-aws-eks"
    }
  )
}

module "vpc" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.5"

  name                  = local.vpc_name
  vpc_cidr              = var.vpc_cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks
  azs                   = local.azs
  public_subnets        = []
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  intra_subnets         = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway    = false
  enable_nat_gateway    = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  create_database_subnet_group = true

  instance_tenancy                  = "default"
  vpc_flow_log_permissions_boundary = var.iam_role_permissions_boundary

  tags = local.tags
}

module "transit_gateway_a" {
  source                                                         = "../../"
  config                                                         = null #local.transit_gateway_config
  tgw_tags                                                       = { Name = "transit-gateway-a" }
  create_transit_gateway                                         = true
  create_transit_gateway_route_table                             = true
  create_transit_gateway_route_table_association_and_propagation = false
  create_transit_gateway_vpc_attachment                          = false
  default_route_table_association                                = "disable"
  default_route_table_propagation                                = "disable"
  ram_resource_share_enabled                                     = false
}

module "transit_gateway_b" {
  source                                                         = "../../"
  config                                                         = null #local.transit_gateway_config
  tgw_tags                                                       = { Name = "transit-gateway-b" }
  create_transit_gateway                                         = true
  create_transit_gateway_route_table                             = true
  create_transit_gateway_route_table_association_and_propagation = false
  create_transit_gateway_vpc_attachment                          = false
  default_route_table_association                                = "disable"
  default_route_table_propagation                                = "disable"
  ram_resource_share_enabled                                     = false
}

### NOTE: The peering attachment request has to be manually accepted as a separate step
resource "aws_ec2_transit_gateway_peering_attachment" "peering_attachment_transit_gateway_a_to_b" {
  peer_region             = var.region
  transit_gateway_id      = module.transit_gateway_a.transit_gateway_id
  peer_transit_gateway_id = module.transit_gateway_b.transit_gateway_id
}

### NOTE: This will fail until the peering attachment request is accepted manually. After that is completed then another apply can be run to create the routes
#add VPC private subnet CIDRs to existing TGW peering attachments route table to enable ingress routing //////////////////////////
# TODO - see if cloudposse module is easier to use
resource "aws_ec2_transit_gateway_route" "vpc_subnet_cidr_route" {
  count                          = length(module.vpc.private_subnets_cidr_blocks) # VPC's private subnet CIDRs
  destination_cidr_block         = module.vpc.private_subnets_cidr_blocks[count.index]
  transit_gateway_route_table_id = module.transit_gateway_a.transit_gateway_route_table_id                                 # ID of TGW A route table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment_transit_gateway_a_to_b.id # ID of TGW A peering attachment
}

data "aws_ec2_transit_gateway_attachments" "peering_attachments" {
  filter {
    name   = "resource-type"
    values = ["peering"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  other_peering_attachment_ids = [for attachment_id in data.aws_ec2_transit_gateway_attachments.peering_attachments.ids :
  attachment_id if attachment_id != aws_ec2_transit_gateway_peering_attachment.peering_attachment_transit_gateway_a_to_b.id]
}

# TODO - see if cloudposse module is easier to use
resource "aws_ec2_transit_gateway_route" "return_route" {
  count                          = length(module.vpc.private_subnets_cidr_blocks) # VPC's private subnet CIDRs
  destination_cidr_block         = module.vpc.private_subnets_cidr_blocks[count.index]
  transit_gateway_route_table_id = module.transit_gateway_b.transit_gateway_route_table_id                                       # ID of TGW B route table
  transit_gateway_attachment_id  = length(local.other_peering_attachment_ids) > 0 ? local.other_peering_attachment_ids[0] : null # ID of TGW B peering attachment
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// create a TGW attachment & TGW Route Table to attach VPC to existing TGW
locals {
  transit_gateway_config = {
    target_vpc = {
      vpc_id                            = module.vpc.vpc_id
      vpc_cidr                          = module.vpc.vpc_cidr_block
      subnet_ids                        = module.vpc.private_subnets
      subnet_route_table_ids            = module.vpc.private_route_table_ids
      route_to                          = null
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = null
      static_routes = [
        {
          blackhole              = false
          destination_cidr_block = "10.200.0.0/16"
        }
      ]
    },
  }
}

data "aws_ec2_transit_gateway_route_table" "route_table" {
  count = var.handle_existing_tgw ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.target_transit_gateway_route_table_name]
  }
}

// TODO - get this to create Associations for the Transit Gateway Route Table (i.e., transit-gateway-a route table should have static routes for VPC Resource type - done by Association? )
module "transit_gateway_attach_and_route_vpc_to_existing" {
  count                                                          = var.handle_existing_tgw ? 1 : 0
  source                                                         = "../../"
  config                                                         = local.transit_gateway_config
  tgw_tags                                                       = local.tags
  create_transit_gateway                                         = false
  create_transit_gateway_route_table                             = false
  create_transit_gateway_route_table_association_and_propagation = false
  create_transit_gateway_vpc_attachment                          = true
  default_route_table_association                                = "disable"
  default_route_table_propagation                                = "disable"
  ram_resource_share_enabled                                     = false

  existing_transit_gateway_id             = data.aws_ec2_transit_gateway_route_table.route_table[0].transit_gateway_id
  existing_transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.route_table[0].id
}

# TODO - add a 0.0.0.0/0 route to a private_subnet that maps to the attached TGW to enable egress routing

# TODO - add allowed egress routes to VPC TGW Route Table (i.e. 0.0.0.0/0 to remote/peering TGW) to enable egress routing