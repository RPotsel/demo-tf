resource "yandex_lb_target_group" "this" {
  name = "${var.name}-lb-tg"
  dynamic "target" {
    for_each = data.yandex_compute_instance.this
    content {
      subnet_id = target.value.network_interface[0].subnet_id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "this" {
  name = var.name

  listener {
    name = "${var.name}-listener"
    port = var.port
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.this.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/healthz"
      }
    }
  }
}

resource "yandex_dns_recordset" "this" {
  count = var.dns_zone != "" ? 1 : 0
  zone_id = data.yandex_dns_zone.this[0].id
  name    = "${yandex_lb_network_load_balancer.this.name}.${data.yandex_dns_zone.this[0].zone}"
  type    = "A"
  ttl     = 200
  data    = [flatten(yandex_lb_network_load_balancer.this.listener[*].external_address_spec).0.address]

  depends_on = [yandex_lb_network_load_balancer.this]
}
