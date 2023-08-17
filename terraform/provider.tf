locals {
  cloud_id           = "b1g8b46i03j5u870g8u6"
  folder_id          = "b1ggf0njdafu0q8tluif" 
  zone               = "ru-central1-a"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}


provider "yandex" {
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
}