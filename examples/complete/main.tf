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
  vpc_name             = "${var.name_prefix}-${lower(random_id.default.hex)}"
  transit_gateway_name = "${var.name_prefix}-tgw-${random_id.default.hex}"
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      ManagedBy    = "Terraform"
      Repo         = "https://github.com/defenseunicorns/terraform-aws-transit-gateway"
    }
  )
}


################################################################################
# VPC
################################################################################

locals {
  azs                            = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
  vpc_prod_cidr_block            = "10.200.0.0/16"
  vpc_prod_secondary_cidr_blocks = ["100.64.0.0/16"]

}

module "vpc_prod" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.13"

  name                         = "prod-${local.vpc_name}"
  vpc_cidr                     = local.vpc_prod_cidr_block
  secondary_cidr_blocks        = local.vpc_prod_secondary_cidr_blocks
  azs                          = local.azs
  public_subnets               = []
  private_subnets              = [for k, v in module.vpc_prod.azs : cidrsubnet(module.vpc_prod.vpc_cidr_block, 5, k + 4)]
  database_subnets             = [for k, v in module.vpc_prod.azs : cidrsubnet(module.vpc_prod.vpc_cidr_block, 5, k + 8)]
  intra_subnets                = [for k, v in module.vpc_prod.azs : cidrsubnet(element(module.vpc_prod.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway           = false
  enable_nat_gateway           = false
  create_default_vpc_endpoints = false

  private_subnet_tags = {
    "kubernetes.io/cluster/prod"      = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
  create_database_subnet_group = true

  instance_tenancy = "default"

  tags = local.tags
}

locals {
  vpc_dev_cidr_block            = "10.201.0.0/16"
  vpc_dev_secondary_cidr_blocks = ["100.64.0.0/16"]
}

module "vpc_dev" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.13"

  name                         = "dev-${local.vpc_name}"
  vpc_cidr                     = local.vpc_dev_cidr_block
  secondary_cidr_blocks        = local.vpc_dev_secondary_cidr_blocks
  azs                          = local.azs
  public_subnets               = []
  private_subnets              = [for k, v in module.vpc_dev.azs : cidrsubnet(module.vpc_dev.vpc_cidr_block, 5, k + 4)]
  database_subnets             = [for k, v in module.vpc_dev.azs : cidrsubnet(module.vpc_dev.vpc_cidr_block, 5, k + 8)]
  intra_subnets                = [for k, v in module.vpc_dev.azs : cidrsubnet(element(module.vpc_dev.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway           = false
  enable_nat_gateway           = false
  create_default_vpc_endpoints = false

  private_subnet_tags = {
    "kubernetes.io/cluster/dev"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
  create_database_subnet_group = true

  instance_tenancy = "default"

  tags = local.tags
}

################################################################################
# New Transit Gateway
# deploy new TGW and route two vpc_prod and vpc_dev together
################################################################################

locals {
  new_transit_gateway_config = {
    prod = {
      vpc_name                                = "prod-${local.vpc_name}"
      vpc_id                                  = module.vpc_prod.vpc_id
      vpc_cidr                                = module.vpc_prod.vpc_cidr_block
      subnet_ids                              = module.vpc_prod.private_subnets
      subnet_route_table_ids                  = module.vpc_prod.private_route_table_ids
      route_to                                = null
      route_to_cidr_blocks                    = [module.vpc_dev.vpc_cidr_block]
      transit_gateway_vpc_attachment_id       = null
      transit_gateway_vpc_attachment_name_tag = null
      static_routes = [
        {
          blackhole                           = false
          destination_cidr_block              = "0.0.0.0/0"
          route_transit_gateway_attachment_id = null
        },
        {
          blackhole                           = false
          destination_cidr_block              = module.vpc_prod.vpc_cidr_block
          route_transit_gateway_attachment_id = null
        }
      ]
    },

    dev = {
      vpc_name                                = "dev-${local.vpc_name}"
      vpc_id                                  = module.vpc_dev.vpc_id
      vpc_cidr                                = module.vpc_dev.vpc_cidr_block
      subnet_ids                              = module.vpc_dev.private_subnets
      subnet_route_table_ids                  = module.vpc_dev.private_route_table_ids
      route_to                                = null
      route_to_cidr_blocks                    = null
      transit_gateway_vpc_attachment_id       = null
      transit_gateway_vpc_attachment_name_tag = null
      static_routes = [
        {
          blackhole                           = false
          destination_cidr_block              = module.vpc_dev.vpc_cidr_block
          route_transit_gateway_attachment_id = null
        }
      ]
    }
  }
}


module "new_transit_gateway" {
  source = "../.."

  create_transit_gateway                         = true
  create_transit_gateway_route_table             = true
  create_transit_gateway_vpc_attachment          = true
  create_transit_gateway_route_table_association = true
  create_transit_gateway_propagation             = false
  transit_gateway_name                           = local.transit_gateway_name
  config                                         = local.new_transit_gateway_config

  depends_on = [module.vpc_dev, module.vpc_prod]
}
################################################################################
# Existing Transit Gateway
# use existing TGW to add a new route to vpc_dev
################################################################################

locals {
  dev_tgw_route_table_only_and_existing_tgw_config = {
    dev = {
      vpc_name                                = "dev-${local.vpc_name}"
      vpc_id                                  = module.vpc_dev.vpc_id
      vpc_cidr                                = module.vpc_dev.vpc_cidr_block
      subnet_ids                              = module.vpc_dev.private_subnets
      subnet_route_table_ids                  = module.vpc_dev.private_route_table_ids
      route_to                                = []
      route_to_cidr_blocks                    = null
      transit_gateway_vpc_attachment_id       = module.new_transit_gateway.transit_gateway_vpc_attachment_ids["dev"]
      transit_gateway_vpc_attachment_name_tag = null
      static_routes = [
        {
          blackhole                           = false
          destination_cidr_block              = module.vpc_dev.vpc_cidr_block
          route_transit_gateway_attachment_id = null
        },
        {
          blackhole                           = false
          destination_cidr_block              = "0.0.0.0/0"
          route_transit_gateway_attachment_id = null
        },
      ]
    }
  }
}

# data "aws_ec2_transit_gateway" "existing" {
#   filter {
#     name   = "tag:Name"
#     values = [local.transit_gateway_name]
#   }
#   depends_on = [module.new_transit_gateway]
# }

module "existing_transit_gateway_new_route_table" {
  source = "../.."

  create_transit_gateway                         = false
  existing_transit_gateway_id                    = module.new_transit_gateway.transit_gateway_id
  create_transit_gateway_route_table             = true
  use_existing_transit_gateway                   = true
  transit_gateway_route_table_name               = "dev-${local.vpc_name}-route-table"
  create_transit_gateway_vpc_attachment          = false # don't need this, already attached to the TGW existing
  create_transit_gateway_route_table_association = false
  create_transit_gateway_propagation             = false

  config = local.dev_tgw_route_table_only_and_existing_tgw_config

  depends_on = [module.new_transit_gateway]

}
