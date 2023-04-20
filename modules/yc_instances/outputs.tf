output "instance_name" {
  description = "The compute instance name"
  value = toset([
    for instance in yandex_compute_instance.this : instance.name
  ])
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value = toset([
    for instance in yandex_compute_instance.this : instance.network_interface.0.ip_address
  ])
}

output "external_ip" {
  description = "The external IP address of the instance"
  value = toset([
    for instance in yandex_compute_instance.this : instance.network_interface.0.nat_ip_address
  ])
}

output "fqdn" {
  description = "The fully qualified DNS name of this instance"
  value = toset([
    for instance in yandex_compute_instance.this : instance.fqdn
  ])
}
