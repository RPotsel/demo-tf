resource "yandex_compute_instance" "this" {
  for_each    = var.instances.names != null ? toset(var.instances.names) : []
  name        = each.key
  hostname    = each.key
  zone        = var.zone
  platform_id = var.platform_id
  labels      = var.instances.labels

  allow_stopping_for_update = var.allow_stopping_for_update

  resources {
    cores          = try(var.instances.cores, 2)
    memory         = try(var.instances.memory, 4)
    core_fraction  = try(var.instances.fraction, null)
  }

  boot_disk {
    initialize_params {
      name        = lookup(var.boot_disk, "name", null)
      type        = lookup(var.boot_disk, "type", null)
      size        = try(var.instances.disk_size, null)
      image_id    = data.yandex_compute_image.this.id
    }
  }

  network_interface {
    subnet_id      = data.yandex_vpc_subnet.this.subnet_id
    nat            = try(var.instances.nat, false)
    security_group_ids = var.instances.sgs != null ? [for v in var.security_groups : v.id if contains(var.instances.sgs, v.name)] : null

    # rpc error: code = InvalidArgument desc = DNS records for one to one NAT are not supported yet
    # dynamic "nat_dns_record" {
    #   for_each = var.dns_zone != {} ? [1] : []
    #   content {
    #     fqdn        = "${each.key}.${data.yandex_dns_zone.this[0].zone}"
    #     ttl         = try(var.instances.ttl, 200)
    #     ptr         = try(var.instances.ptr, false)
    #     dns_zone_id = data.yandex_dns_zone.this[0].dns_zone_id
    #   }
    # }
  }

  metadata = {
    serial-port-enable = "1"
    user-data          = var.user_data != "" ? var.user_data : data.template_file.this.rendered
  }
}

resource "yandex_dns_recordset" "this" {
  for_each = var.dns_zone != "" ? {for k,v in yandex_compute_instance.this : k => v if v.network_interface[0].nat} : {}
  zone_id = data.yandex_dns_zone.this[0].id
  name    = "${each.value.name}.${data.yandex_dns_zone.this[0].zone}"
  type    = "A"
  ttl     = 200
  data    = ["${each.value.network_interface[0].nat_ip_address}"]

  depends_on = [yandex_compute_instance.this]
}
