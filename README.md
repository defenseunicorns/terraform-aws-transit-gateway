# terraform-aws-transit-gateway
Repo provides module to create (or not, if already existing) transit gateway(s), handle attachments, and routes, and more
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.30.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.30.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_subnet_route"></a> [subnet\_route](#module\_subnet\_route) | ./modules/subnet_route | n/a |
| <a name="module_transit_gateway_route"></a> [transit\_gateway\_route](#module\_transit\_gateway\_route) | ./modules/transit_gateway_route | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_accept_shared_attachments"></a> [auto\_accept\_shared\_attachments](#input\_auto\_accept\_shared\_attachments) | Whether resource attachment requests are automatically accepted. Valid values: `disable`, `enable`. Default value: `disable` | `string` | `"disable"` | no |
| <a name="input_config"></a> [config](#input\_config) | Configuration for VPC attachments, Transit Gateway routes, and subnet routes | <pre>map(object({<br>    vpc_name                          = string<br>    vpc_id                            = string<br>    vpc_cidr                          = string<br>    subnet_ids                        = set(string)<br>    subnet_route_table_ids            = set(string)<br>    route_to                          = set(string)<br>    route_to_cidr_blocks              = set(string)<br>    transit_gateway_vpc_attachment_id = string<br>    static_routes = set(object({<br>      blackhole              = bool<br>      destination_cidr_block = string<br>    }))<br>  }))</pre> | `null` | no |
| <a name="input_create_transit_gateway"></a> [create\_transit\_gateway](#input\_create\_transit\_gateway) | Whether to create a Transit Gateway. If set to `false`, an existing Transit Gateway ID must be provided in the variable `existing_transit_gateway_id` | `bool` | `true` | no |
| <a name="input_create_transit_gateway_propagation"></a> [create\_transit\_gateway\_propagation](#input\_create\_transit\_gateway\_propagation) | Whether to enable Transit Gateway propagation on the specified route table and attachment | `bool` | `true` | no |
| <a name="input_create_transit_gateway_route_table"></a> [create\_transit\_gateway\_route\_table](#input\_create\_transit\_gateway\_route\_table) | Whether to create a Transit Gateway Route Table. If set to `false`, an existing Transit Gateway Route Table ID must be provided in the variable `existing_transit_gateway_route_table_id` | `bool` | `true` | no |
| <a name="input_create_transit_gateway_route_table_association"></a> [create\_transit\_gateway\_route\_table\_association](#input\_create\_transit\_gateway\_route\_table\_association) | Whether to create Transit Gateway Route Table association | `bool` | `true` | no |
| <a name="input_create_transit_gateway_vpc_attachment"></a> [create\_transit\_gateway\_vpc\_attachment](#input\_create\_transit\_gateway\_vpc\_attachment) | Whether to create Transit Gateway VPC Attachments | `bool` | `true` | no |
| <a name="input_default_route_table_association"></a> [default\_route\_table\_association](#input\_default\_route\_table\_association) | Whether resource attachments are automatically associated with the default association route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"disable"` | no |
| <a name="input_default_route_table_propagation"></a> [default\_route\_table\_propagation](#input\_default\_route\_table\_propagation) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `disable` | `string` | `"disable"` | no |
| <a name="input_dns_support"></a> [dns\_support](#input\_dns\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |
| <a name="input_existing_transit_gateway_id"></a> [existing\_transit\_gateway\_id](#input\_existing\_transit\_gateway\_id) | Existing Transit Gateway ID. If provided, the module will not create a Transit Gateway but instead will use the existing one | `string` | `null` | no |
| <a name="input_existing_transit_gateway_route_table_id"></a> [existing\_transit\_gateway\_route\_table\_id](#input\_existing\_transit\_gateway\_route\_table\_id) | Existing Transit Gateway Route Table ID. If provided, the module will not create a Transit Gateway Route Table but instead will use the existing one | `string` | `null` | no |
| <a name="input_route_keys_enabled"></a> [route\_keys\_enabled](#input\_route\_keys\_enabled) | If true, Terraform will use keys to label routes, preventing unnecessary changes,<br>but this requires that the VPCs and subnets already exist before using this module.<br>If false, Terraform will use numbers to label routes, and a single change may<br>cascade to a long list of changes because the index or order has changed, but<br>this will work when the `true` setting generates the error `The "for_each" value depends on resource attributes...` | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_transit_gateway_cidr_blocks"></a> [transit\_gateway\_cidr\_blocks](#input\_transit\_gateway\_cidr\_blocks) | The list of associated CIDR blocks. It can contain up to 1 IPv4 CIDR block<br>of size up to /24 and up to one IPv6 CIDR block of size up to /64. The IPv4<br>block must not be from range 169.254.0.0/16. | `list(string)` | `null` | no |
| <a name="input_transit_gateway_description"></a> [transit\_gateway\_description](#input\_transit\_gateway\_description) | Transit Gateway description. If not provided, one will be automatically generated. | `string` | `""` | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | The name of the Transit Gateway | `string` | `""` | no |
| <a name="input_transit_gateway_route_table_name"></a> [transit\_gateway\_route\_table\_name](#input\_transit\_gateway\_route\_table\_name) | The name of the Transit Gateway Route Table | `string` | `""` | no |
| <a name="input_use_existing_transit_gateway"></a> [use\_existing\_transit\_gateway](#input\_use\_existing\_transit\_gateway) | Whether to use an existing Transit Gateway. If set to `true`, an existing Transit Gateway ID must be provided in the variable `existing_transit_gateway_id` | `bool` | `false` | no |
| <a name="input_vpc_attachment_appliance_mode_support"></a> [vpc\_attachment\_appliance\_mode\_support](#input\_vpc\_attachment\_appliance\_mode\_support) | Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: `disable`, `enable` | `string` | `"disable"` | no |
| <a name="input_vpc_attachment_dns_support"></a> [vpc\_attachment\_dns\_support](#input\_vpc\_attachment\_dns\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |
| <a name="input_vpc_attachment_ipv6_support"></a> [vpc\_attachment\_ipv6\_support](#input\_vpc\_attachment\_ipv6\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `disable` | `string` | `"disable"` | no |
| <a name="input_vpn_ecmp_support"></a> [vpn\_ecmp\_support](#input\_vpn\_ecmp\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_cidr_blocks"></a> [destination\_cidr\_blocks](#output\_destination\_cidr\_blocks) | Destination CIDR blocks |
| <a name="output_route_config_list"></a> [route\_config\_list](#output\_route\_config\_list) | Route configuration list |
| <a name="output_route_config_map"></a> [route\_config\_map](#output\_route\_config\_map) | Route configuration map |
| <a name="output_subnet_route_ids"></a> [subnet\_route\_ids](#output\_subnet\_route\_ids) | Subnet route identifiers combined with destinations |
| <a name="output_transit_gateway_arn"></a> [transit\_gateway\_arn](#output\_transit\_gateway\_arn) | Transit Gateway ARN |
| <a name="output_transit_gateway_association_default_route_table_id"></a> [transit\_gateway\_association\_default\_route\_table\_id](#output\_transit\_gateway\_association\_default\_route\_table\_id) | Transit Gateway association default route table ID |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | Transit Gateway ID |
| <a name="output_transit_gateway_propagation_default_route_table_id"></a> [transit\_gateway\_propagation\_default\_route\_table\_id](#output\_transit\_gateway\_propagation\_default\_route\_table\_id) | Transit Gateway propagation default route table ID |
| <a name="output_transit_gateway_route_ids"></a> [transit\_gateway\_route\_ids](#output\_transit\_gateway\_route\_ids) | Transit Gateway route identifiers combined with destinations |
| <a name="output_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#output\_transit\_gateway\_route\_table\_id) | Transit Gateway route table ID |
| <a name="output_transit_gateway_vpc_attachment_ids"></a> [transit\_gateway\_vpc\_attachment\_ids](#output\_transit\_gateway\_vpc\_attachment\_ids) | Transit Gateway VPC attachment IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
