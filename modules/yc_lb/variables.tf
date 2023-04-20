variable "name" {
  type        = string
  description = "Objects prefix name"
}

variable "instances" {
  type        = list(string)
  description = "Network Load Balancer target instances"
}

variable "port" {
  type        = string
  description = "Network Load Balancer port"
}

variable "dns_zone" {
  default     = ""
  description = "(Optional) Yandex Cloud public DNS zone name for external or nat addresses"
}
