# Provider
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84"
    }
  }
  backend "s3" {
    endpoint                = "storage.yandexcloud.net"
    bucket                  = "degree-project"
    region                  = "ru-central1"
    key                     = "terraform.tfstate"
    shared_credentials_file = "backend.cred"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  # token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}
