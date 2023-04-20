data "yandex_compute_instance" "this"  {
  count = length(var.instances)
  name  = var.instances[count.index]
}

data "yandex_dns_zone" "this" {
  count = var.dns_zone != "" ? 1 : 0
  name  = var.dns_zone
}
