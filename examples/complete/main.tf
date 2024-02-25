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

module "setup transit_gateways_and_peering" {
  count  = var.create_transit_gateway ? 1 : 0
  source = "../transit-gateway-peering"
  region = var.region
}

module "transit_gateway_attach_vpc_and_route" {
  source = "../.."
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  tags                            = local.tags
  vpc_route_table_id              = module.vpc.vpc_main_route_table_id
  target_transit_gateway_tag_name = var.target_transit_gateway_tag_name
  peered_transit_gateway_tag_name = var.peered_transit_gateway_tag_name
}