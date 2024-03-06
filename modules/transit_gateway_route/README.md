# transit_gateway_route

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
| [aws_ec2_transit_gateway_route.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_route_config"></a> [route\_config](#input\_route\_config) | Route config | <pre>list(object({<br>    blackhole              = bool<br>    destination_cidr_block = string<br>  }))</pre> | n/a | yes |
| <a name="input_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#input\_transit\_gateway\_attachment\_id) | Transit Gateway VPC attachment ID | `string` | n/a | yes |
| <a name="input_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#input\_transit\_gateway\_route\_table\_id) | Transit Gateway route table ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transit_gateway_route_ids"></a> [transit\_gateway\_route\_ids](#output\_transit\_gateway\_route\_ids) | Transit Gateway route identifiers combined with destinations |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
