# subnet_route

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_cidr_blocks"></a> [destination\_cidr\_blocks](#input\_destination\_cidr\_blocks) | Destination CIDR blocks | `list(string)` | `null` | no |
| <a name="input_route_keys_enabled"></a> [route\_keys\_enabled](#input\_route\_keys\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | Subnet route table IDs | `list(string)` | `null` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | Transit Gateway ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destrination_cidr_blocks"></a> [destrination\_cidr\_blocks](#output\_destrination\_cidr\_blocks) | Destination CIDR blocks |
| <a name="output_route_config_list"></a> [route\_config\_list](#output\_route\_config\_list) | Route configuration list |
| <a name="output_route_config_map"></a> [route\_config\_map](#output\_route\_config\_map) | Route configuration map |
| <a name="output_subnet_route_ids"></a> [subnet\_route\_ids](#output\_subnet\_route\_ids) | Subnet route identifiers combined with destinations |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
