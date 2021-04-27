
########
# Label
########
variable "name" {
  description = "The name to give the ASG and associated resources"
  type        = string
  default     = ""
}

variable "lc_name" {
  description = "The name to give the launch configuration - defaults to 'name'"
  type        = string
  default     = ""
}

variable "id" {
  description = "The id to give the ami"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to give resource"
  type        = map(string)
  default     = {}
}




