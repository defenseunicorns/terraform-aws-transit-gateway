variable "subnet_ids" {
  description = "The subnet IDs to use for the TGW attachment"
  type        = set(string)
}

variable "vpc_id" {
  description = "The VPC ID to attach to the TGW"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the TGW attachment"
  type        = map(string)
  default     = {}
}

variable "vpc_route_table_id" {
  description = "The ID of the VPC route table to use for the TGW route"
  type        = string
}

variable "target_transit_gateway_tag_name" {
  description = "The value of the Name tag"
  type        = string
}

variable "routes_config" {
  type = map(object({
    attachment_id       = string
    route_to_cidr_block = string
  }))

  description = "Routes for VPC attachments"
  default     = null
}

variable "peered_route_table_id" {
  description = "The id of the main route table of the transit gateway peer (the tgw on the other side of the tgw that our VPC is attached)"
  default     = ""
}

variable "peered_attachment_id" {
  description = "The id of the attachment of type Peering that is attached to the tgw on the other side of the tgs that our VPC is attached"
  default     = ""
}
