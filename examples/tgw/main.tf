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
  vpc_name = "${var.name_prefix}-${lower(random_id.default.hex)}"
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
  azs = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
}

module "vpc_prod" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.5"

  name                         = "prod-${local.vpc_name}"
  vpc_cidr                     = "10.200.0.0/16"
  secondary_cidr_blocks        = ["100.64.0.0/16"]
  azs                          = local.azs
  public_subnets               = [for k, v in module.vpc_prod.azs : cidrsubnet(module.vpc_prod.vpc_cidr_block, 5, k)]
  private_subnets              = [for k, v in module.vpc_prod.azs : cidrsubnet(module.vpc_prod.vpc_cidr_block, 5, k + 4)]
  database_subnets             = [for k, v in module.vpc_prod.azs : cidrsubnet(module.vpc_prod.vpc_cidr_block, 5, k + 8)]
  intra_subnets                = [for k, v in module.vpc_prod.azs : cidrsubnet(element(module.vpc_prod.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway           = true
  enable_nat_gateway           = true
  create_default_vpc_endpoints = false

  private_subnet_tags = {
    "kubernetes.io/cluster/prod"      = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
  create_database_subnet_group = true

  instance_tenancy = "default"

  tags = local.tags
}

module "vpc_dev" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.5"

  name                         = "dev-${local.vpc_name}"
  vpc_cidr                     = "10.201.0.0/16"
  secondary_cidr_blocks        = ["100.64.0.0/16"]
  azs                          = local.azs
  public_subnets               = [for k, v in module.vpc_dev.azs : cidrsubnet(module.vpc_dev.vpc_cidr_block, 5, k)]
  private_subnets              = [for k, v in module.vpc_dev.azs : cidrsubnet(module.vpc_dev.vpc_cidr_block, 5, k + 4)]
  database_subnets             = [for k, v in module.vpc_dev.azs : cidrsubnet(module.vpc_dev.vpc_cidr_block, 5, k + 8)]
  intra_subnets                = [for k, v in module.vpc_dev.azs : cidrsubnet(element(module.vpc_dev.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway           = true
  enable_nat_gateway           = true
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
# Transit Gateway
################################################################################

locals {
  transit_gateway_config = {
    prod = {
      vpc_id                            = module.vpc_prod.vpc_id
      vpc_cidr                          = module.vpc_prod.vpc_cidr_block
      subnet_ids                        = module.vpc_prod.private_subnets
      subnet_route_table_ids            = module.vpc_prod.private_route_table_ids
      route_to                          = ["dev"]
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = null
      static_routes = [
        {
          blackhole              = false
          destination_cidr_block = "0.0.0.0/0"
        },
        {
          blackhole              = false
          destination_cidr_block = "172.16.1.0/24"
        }
      ]
    },

    dev = {
      vpc_id                            = module.vpc_dev.vpc_id
      vpc_cidr                          = module.vpc_dev.vpc_cidr_block
      subnet_ids                        = module.vpc_dev.private_subnets
      subnet_route_table_ids            = module.vpc_dev.private_route_table_ids
      route_to                          = ["prod"]
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = null
      static_routes                     = null
    }
  }
}

module "transit_gateway" {
  source = "../.."

  create_transit_gateway                         = true
  create_transit_gateway_route_table             = true
  create_transit_gateway_vpc_attachment          = true
  create_transit_gateway_route_table_association = true
  create_transit_gateway_propagation             = false

  config = local.transit_gateway_config
}
