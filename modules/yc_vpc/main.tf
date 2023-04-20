data "yandex_vpc_network" "this" {
  name        = var.virtual_private_cloud.name
  folder_id   = var.folder_id
}

resource "yandex_vpc_subnet" "this" {
  for_each       = { for k, v in var.virtual_private_cloud.subnets : k => v }
  description    = lookup(each.value, "description", null)
  folder_id      = lookup(each.value, "folder_id", null)
  v4_cidr_blocks = lookup(each.value, "cidr4")
  labels         = lookup(each.value, "labels", null)
  name           = lookup(each.value, "name", null)
  zone           = lookup(each.value, "zone")
  network_id     = data.yandex_vpc_network.this.id
}

resource "yandex_vpc_security_group" "this" {
  for_each    = { for k, v in var.security_groups : k => v }
  network_id  = data.yandex_vpc_network.this.id
  name        = lookup(each.value, "name", null)
  description = lookup(each.value, "description", null)

  dynamic "ingress" {
    for_each    = { for k, v in each.value.ingress : k => v }
    iterator    = ingress
    content {
      description       = lookup(ingress.value, "description", null)
      protocol          = lookup(ingress.value, "protocol", null)
      labels            = lookup(ingress.value, "labels", null)
      from_port         = lookup(ingress.value, "from_port", null)
      to_port           = lookup(ingress.value, "to_port", null)
      port              = lookup(ingress.value, "port", null)
      v4_cidr_blocks    = lookup(ingress.value, "cidr4", null)
      v6_cidr_blocks    = lookup(ingress.value, "cidr6", null)
      predefined_target = lookup(ingress.value, "predefined", null)
    }
  }

  dynamic "egress" {
    for_each    = { for k, v in each.value.egress : k => v }
    iterator    = egress
    content {
      description       = lookup(egress.value, "description", null)
      protocol          = lookup(egress.value, "protocol", null)
      labels            = lookup(egress.value, "labels", null)
      from_port         = lookup(egress.value, "from_port", null)
      to_port           = lookup(egress.value, "to_port", null)
      port              = lookup(egress.value, "port", null)
      v4_cidr_blocks    = lookup(egress.value, "cidr4", null)
      v6_cidr_blocks    = lookup(egress.value, "cidr6", null)
      predefined_target = lookup(egress.value, "predefined", null)
    }
  }
}
