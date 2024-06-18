# complete

<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.34 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.34 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_transit_gateway_new_route_table"></a> [existing\_transit\_gateway\_new\_route\_table](#module\_existing\_transit\_gateway\_new\_route\_table) | ../.. | n/a |
| <a name="module_new_transit_gateway"></a> [new\_transit\_gateway](#module\_new\_transit\_gateway) | ../.. | n/a |
| <a name="module_vpc_dev"></a> [vpc\_dev](#module\_vpc\_dev) | git::https://github.com/defenseunicorns/terraform-aws-vpc.git | v0.1.9 |
| <a name="module_vpc_prod"></a> [vpc\_prod](#module\_vpc\_prod) | git::https://github.com/defenseunicorns/terraform-aws-vpc.git | v0.1.9 |

## Resources

| Name | Type |
|------|------|
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to use when naming all resources | `string` | `"ex-complete"` | no |
| <a name="input_num_azs"></a> [num\_azs](#input\_num\_azs) | The number of AZs to use | `number` | `3` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_new_transit_gateway"></a> [new\_transit\_gateway](#output\_new\_transit\_gateway) | n/a |
| <a name="output_new_transit_gateway_config"></a> [new\_transit\_gateway\_config](#output\_new\_transit\_gateway\_config) | n/a |
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
