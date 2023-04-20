module "vpc" {
  source                = "../modules/yc_vpc"
  virtual_private_cloud = var.vpc
  security_groups       = var.sgs
}

module "instances" {
  source          = "../modules/yc_instances"
  for_each        = { for k, v in var.vms : k => v }
  instances       = each.value
  zone            = "ru-central1-a"
  platform_id     = "standard-v1"
  image_family    = var.family_images_linux
  security_groups = module.vpc.yandex_vpc_security_groups
  dns_zone        = var.dns_zone

  username = var.ssh_user
  ssh_key  = file(var.ssh_pubkey)

  allow_stopping_for_update = true

  boot_disk = {
    type     = "network-hdd"
  }

  depends_on = [module.vpc]
}

module lb {
  source    = "../modules/yc_lb/"
  for_each  = { for k, v in var.lb : k => v }
  name      = each.value.name
  instances = each.value.instances
  port      = each.value.port
  dns_zone  = var.dns_zone

  depends_on = [module.instances]
}
