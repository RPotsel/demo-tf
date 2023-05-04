variable "folder_id" {
  default = null
  description = "(Optional) ID of the folder that the resource belongs to. If it is not provided, the default provider folder is used."
}

variable "virtual_private_cloud" {
  type = object({
    name = string
    rt   = optional(string)
    subnets = list(object({
      name    = string
      zone    = string
      cidr4   = list(string)
      labels  = map(string)
    }))
    labels = map(string)
  })
  description = "Virtual Private Cloud description"
}

variable "security_groups" {
  type = list(object({
    name    = string
    description = string
    egress = list(object({
      protocol    = string
      description = string
      from_port   = optional(string)
      to_port     = optional(string)
      port        = optional(string)
      cidr4       = optional(list(string))
      predefined  = optional(string)
    }))
    ingress = list(object({
      protocol    = string
      description = string
      from_port   = optional(string)
      to_port     = optional(string)
      port        = optional(string)
      cidr4       = optional(list(string))
      predefined  = optional(string)
    }))
  }))
  description = "Security groups description"
}
