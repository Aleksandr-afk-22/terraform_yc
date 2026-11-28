terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.250.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.sa_key_file
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.yc_zone

  # Ключи для S3-совместимого API Object Storage
  storage_access_key = var.storage_access_key
  storage_secret_key = var.storage_secret_key
}