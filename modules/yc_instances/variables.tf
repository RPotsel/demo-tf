variable "instances" {
  type = object({
    names     = list(string)
    subnet    = string
    nat       = optional(bool)
    cores     = number
    fraction  = number
    memory    = number
    disk_size = number
    labels    = map(string)
    sgs       = optional(list(string))
  })
  description = "VMs description"
}

variable "platform_id" {
  default = null
  description = "(Optional) The type of virtual machine to create. The default is 'standard-v1'."
}

variable "zone" {
  default = null
  description = "(Optional) The availability zone where the virtual machine will be created. If it is not provided, the default provider folder is used."
}

variable "boot_disk" {
  default = {}
  description = "(Required) The boot disk for the instance."
}

variable "image_family" {
  default     = null
  description = "Family of images in Yandex Cloud. The default is ubuntu-2004-lts"
}

variable "dns_zone" {
  default     = ""
  description = "(Optional) Yandex Cloud public DNS zone name for external or nat addresses"
}

variable "security_groups" {
  default = []
  description = "(Required) Secutity groups for creation in VPC"
}

variable "username" {
  default = ""
  description = "(Optional) Provide username for creation on instance with cloud-init."
}

variable "password" {
  default = ""
  description = "(Optional) Provide password for creation on instance with cloud-init for user."
}

variable "user_groups" {
  default = "sudo"
  description = "(Optional) Provide groups to assign to user on compute instance."
}

variable "ssh_key" {
  default = ""
  description = "(Optional) Provide public ssh_key to assign to user on compute instance."
}

variable "user_data" {
  default = ""
  description = "(Optional) Custom user-data for compute instance."
}

variable "allow_stopping_for_update" {
  default = false
  description = "(Optional) Custom user-data for compute instance."
}
