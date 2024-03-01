###########################################################
################## Global Settings ########################

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "name_prefix" {
  description = "The prefix to use when naming all resources"
  type        = string
  default     = "ex-complete"
  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "The name prefix cannot be more than 20 characters"
  }
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for IAM roles"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

###########################################################
#################### VPC Config ###########################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "secondary_cidr_blocks" {
  description = "A list of secondary CIDR blocks for the VPC"
  type        = list(string)
  default     = []
}

variable "num_azs" {
  description = "The number of AZs to use"
  type        = number
  default     = 3
}

variable "create_transit_gateway" {
  description = "Whether to create a transit gateway"
  type        = bool
  default     = false
}

variable "target_transit_gateway_tag_name" {
  description = "The value of the Name tag"
  type        = string
}
