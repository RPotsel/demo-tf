output "yandex_vpc_network" {
  value = data.yandex_vpc_network.this
}
output "yandex_vpc_subnets" {
  value = yandex_vpc_subnet.this
}
output "yandex_vpc_security_groups" {
  value = yandex_vpc_security_group.this
}
