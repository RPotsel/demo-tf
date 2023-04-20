data "yandex_compute_image" "this" {
  family = var.image_family != null ? var.image_family : "ubuntu-2004-lts"
}

data "yandex_vpc_subnet" "this" {
  name = var.instances.subnet
}

data "yandex_dns_zone" "this" {
  count = var.dns_zone != "" ? 1 : 0
  name  = var.dns_zone
}

data "template_file" "this" {
  template = file("${path.module}/files/cloud-config")

  vars = {
    username    = var.username
    password    = var.password
    ssh_key     = var.ssh_key
    user_groups = var.user_groups
  }
}
