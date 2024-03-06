variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "route_table_ids" {
  type        = list(string)
  description = "Subnet route table IDs"
  default     = null
}

variable "destination_cidr_blocks" {
  type        = list(string)
  description = "Destination CIDR blocks"
  default     = null
}

variable "route_keys_enabled" {
  type    = bool
  default = false
}
