variable "auto_accept_shared_attachments" {
  type        = string
  default     = "disable"
  description = "Whether resource attachment requests are automatically accepted. Valid values: `disable`, `enable`. Default value: `disable`"
}

variable "transit_gateway_name" {
  type        = string
  description = "The name of the Transit Gateway"
  default     = ""
}

variable "transit_gateway_route_table_name" {
  type        = string
  description = "The name of the Transit Gateway Route Table"
  default     = ""
}

variable "default_route_table_association" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments are automatically associated with the default association route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "default_route_table_propagation" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `disable`"
}

variable "dns_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "vpn_ecmp_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "vpc_attachment_appliance_mode_support" {
  type        = string
  default     = "disable"
  description = "Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: `disable`, `enable`"
}

variable "vpc_attachment_dns_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "vpc_attachment_ipv6_support" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `disable`"
}

variable "config" {
  type = map(object({
    vpc_name                          = string
    vpc_id                            = string
    vpc_cidr                          = string
    subnet_ids                        = set(string)
    subnet_route_table_ids            = set(string)
    route_to                          = set(string)
    route_to_cidr_blocks              = set(string)
    transit_gateway_vpc_attachment_id = string
    static_routes = set(object({
      blackhole              = bool
      destination_cidr_block = string
    }))
  }))

  description = "Configuration for VPC attachments, Transit Gateway routes, and subnet routes"
  default     = null
}

variable "existing_transit_gateway_id" {
  type        = string
  default     = null
  description = "Existing Transit Gateway ID. If provided, the module will not create a Transit Gateway but instead will use the existing one"
}

variable "use_existing_transit_gateway" {
  type        = bool
  default     = false
  description = "Whether to use an existing Transit Gateway. If set to `true`, an existing Transit Gateway ID must be provided in the variable `existing_transit_gateway_id`"
}

variable "existing_transit_gateway_route_table_id" {
  type        = string
  default     = null
  description = "Existing Transit Gateway Route Table ID. If provided, the module will not create a Transit Gateway Route Table but instead will use the existing one"
}

variable "create_transit_gateway" {
  type        = bool
  default     = true
  description = "Whether to create a Transit Gateway. If set to `false`, an existing Transit Gateway ID must be provided in the variable `existing_transit_gateway_id`"
}

variable "create_transit_gateway_route_table" {
  type        = bool
  default     = true
  description = "Whether to create a Transit Gateway Route Table. If set to `false`, an existing Transit Gateway Route Table ID must be provided in the variable `existing_transit_gateway_route_table_id`"
}

variable "create_transit_gateway_vpc_attachment" {
  type        = bool
  default     = true
  description = "Whether to create Transit Gateway VPC Attachments"
}

variable "create_transit_gateway_route_table_association" {
  type        = bool
  default     = true
  description = "Whether to create Transit Gateway Route Table association"
}

variable "create_transit_gateway_propagation" {
  type        = bool
  default     = true
  description = "Whether to enable Transit Gateway propagation on the specified route table and attachment"
}

variable "route_keys_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    If true, Terraform will use keys to label routes, preventing unnecessary changes,
    but this requires that the VPCs and subnets already exist before using this module.
    If false, Terraform will use numbers to label routes, and a single change may
    cascade to a long list of changes because the index or order has changed, but
    this will work when the `true` setting generates the error `The "for_each" value depends on resource attributes...`
    EOT
}

variable "transit_gateway_cidr_blocks" {
  type        = list(string)
  default     = null
  description = <<-EOT
    The list of associated CIDR blocks. It can contain up to 1 IPv4 CIDR block
    of size up to /24 and up to one IPv6 CIDR block of size up to /64. The IPv4
    block must not be from range 169.254.0.0/16.
  EOT
}

variable "transit_gateway_description" {
  type        = string
  default     = ""
  description = "Transit Gateway description. If not provided, one will be automatically generated."
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
