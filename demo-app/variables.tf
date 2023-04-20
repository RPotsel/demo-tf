variable "yc_token" {
  type        = string
  description = "Yandex Cloud API key"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud id"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-a"
}

variable "dns_zone" {
  type        = string
  description = "Yandex Cloud public DNS zone name for external or nat addresses"
  default     = ""
}

variable "family_images_linux" {
  type        = string
  description = "Family of images in Yandex Cloud"
  default     = "ubuntu-2004-lts"
}

variable "ssh_user" {
  type        = string
  description = "ssh_user"
  default     = "ubuntu"
}

variable "ssh_pubkey" {
  description = "SSH public key for access to the instance"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vpc" {
  default = {}
  description = "Virtual Private Cloud for creation"
}

variable "sgs" {
  default = []
  description = "Secutity groups for creation in VPC"
}

variable "vms" {
  default = []
  description = "Virtual machines description"
}

variable "lb" {
  type = list(object({
    name      = string
    instances = list(string)
    port      = string
  }))
  default = []
  description = "Network Load description"
}
