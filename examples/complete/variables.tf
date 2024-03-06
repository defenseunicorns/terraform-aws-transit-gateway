###########################################################
# Global Config
###########################################################
variable "name_prefix" {
  description = "The prefix to use when naming all resources"
  type        = string
  default     = "ex-complete"
  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "The name prefix cannot be more than 20 characters"
  }
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

###########################################################
# VPC Config
###########################################################

variable "num_azs" {
  description = "The number of AZs to use"
  type        = number
  default     = 3
}

###########################################################
# Transit Gateway Config
###########################################################
