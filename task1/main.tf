# ── VPC ─────────────────────────────────────────────────────
resource "yandex_vpc_network" "this" {
  name = var.vpc_name
}

# ── Публичная подсеть ───────────────────────────────────────
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# ── Приватная подсеть ───────────────────────────────────────
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  route_table_id = yandex_vpc_route_table.this.id
}

# ── Таблица маршрутизации ───────────────────────────────────
resource "yandex_vpc_route_table" "this" {
  name       = "private-rt"
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.nat_ip
  }
}

# ── NAT-инстанс (публичная подсеть) ─────────────────────────
resource "yandex_compute_instance" "nat" {
  name     = "nat-instance"
  hostname = "nat-instance"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5   # экономия: гарантированная доля CPU 5%
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = var.nat_ip
    nat        = true   # публичный IP (ephemeral)
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }
}

# ── ВМ в публичной подсети (bastion) ────────────────────────
resource "yandex_compute_instance" "public" {
  name     = "vm-public"
  hostname = "vm-public"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }
}

# ── ВМ в приватной подсети ──────────────────────────────────
resource "yandex_compute_instance" "private" {
  name     = "vm-private"
  hostname = "vm-private"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    # без nat — только внутренний IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }
}
