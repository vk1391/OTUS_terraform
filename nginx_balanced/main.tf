locals {
  ssh_key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}

resource "yandex_vpc_network" "vpc" {
  # folder_id = var.folder_id
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "public_subnet" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.pub_subnet_cidrs
  zone           = var.zone
  name           = var.pub_subnet_name
  network_id = yandex_vpc_network.vpc.id
}
resource "yandex_vpc_subnet" "private_subnet" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.subnet_cidrs
  zone           = var.zone
  name           = var.subnet_name
  network_id = yandex_vpc_network.vpc.id
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "nat-instance-sg"
  network_id = yandex_vpc_network.vpc.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
ingress {
    protocol       = "ICMP"
    description    = "icmp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "update"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 871
  }
  ingress {
    protocol       = "TCP"
    description    = "ftp"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 21
  }
}

resource "yandex_compute_instance" "balance_nginx" {
  name        = var.vm_name
  hostname    = var.vm_name
  platform_id = var.platform_id
  zone        = var.zone
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "backend_nginx1" {
  name        = var.vm_name2
  hostname    = var.vm_name2
  platform_id = var.platform_id
  zone        = var.zone
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "backend_nginx2" {
  name        = var.vm_name3
  hostname    = var.vm_name3
  platform_id = var.platform_id
  zone        = var.zone
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "db" {
  name        = var.vm_name4
  hostname    = var.vm_name4
  platform_id = var.platform_id
  zone        = var.zone
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.balance_nginx.network_interface.0.ip_address
  }
}