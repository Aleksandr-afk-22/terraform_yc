# ── Object Storage: бакет и картинка ────────────────────────────

resource "yandex_storage_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "yandex_storage_object" "picture" {
  bucket       = yandex_storage_bucket.site.bucket
  key          = basename(var.picture_path)
  source       = var.picture_path
  content_type = "image/png"
  acl          = "public-read"
}

# ── Сеть ────────────────────────────────────────────────────────

resource "yandex_vpc_network" "net" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.vpc_name}-public"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# ── Security Group: HTTP и SSH отовсюду ─────────────────────────

resource "yandex_vpc_security_group" "web" {
  name        = "${var.vpc_name}-web-sg"
  network_id  = yandex_vpc_network.net.id
  description = "Доступ к вебу (80) и SSH (22) для Instance Group task2"

  ingress {
    protocol       = "tcp"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP отовсюду"
  }

  ingress {
    protocol       = "tcp"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH отовсюду"
  }

  egress {
    protocol       = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Исходящий трафик разрешён"
  }
}

# ── Сервисный аккаунт для Instance Group ────────────────────────

resource "yandex_iam_service_account" "ig" {
  name        = "netology-ig-sa"
  description = "Сервисный аккаунт для Instance Group (task2)"
}

# Роль editor этому СА выдаётся вручную через yc CLI (вариант B),
# поэтому в манифесте iam_binding нет.

# ── Instance Group: 3 ВМ LAMP + health check + target group ─────

resource "yandex_compute_instance_group" "lamp" {
  name               = "lamp-ig"
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.ig.id

  allocation_policy {
    zones = [var.yc_zone]
  }

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.net.id
      subnet_ids         = [yandex_vpc_subnet.public.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.web.id]
    }

    scheduling_policy {
      preemptible = var.vm_web_preemptible
    }

    metadata = {
      ssh-keys  = "${var.ssh_user}:${file(var.ssh_key_path)}"
      user-data = <<-USERDATA
      #!/bin/bash
      # На всякий случай снимаем внутренний файрвол образа
      ufw disable || true
      iptables -F || true
      iptables -P INPUT ACCEPT || true
      cat > /var/www/html/index.html <<HTML
      <!DOCTYPE html>
      <html lang="ru">
      <head><meta charset="utf-8"><title>Netology task2 - LAMP IG</title></head>
      <body style="font-family: sans-serif; max-width: 800px; margin: 40px auto;">
        <h1>LAMP Instance Group: server $(hostname)</h1>
        <p>Картинка из Yandex Object Storage:</p>
        <img src="https://storage.yandexcloud.net/${yandex_storage_bucket.site.bucket}/${yandex_storage_object.picture.key}" alt="task" width="640">
      </body>
      </html>
      HTML
      USERDATA
    }
  }

  scale_policy {
    fixed_scale {
      size = var.ig_size
    }
  }

  deploy_policy {
    max_unavailable  = 1
    max_expansion    = 0
    max_creating     = 2
    max_deleting     = 2
    startup_duration = 300
  }

  health_check {
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    http_options {
      port = 80
      path = "/"
    }
  }

  load_balancer {
    target_group_name = "lamp-tg"
  }
}

# ── Сетевой балансировщик ───────────────────────────────────────

resource "yandex_lb_network_load_balancer" "lamp_nlb" {
  name      = "lamp-nlb"
  folder_id = var.yc_folder_id

  listener {
    name        = "http"
    port        = 80
    target_port = 80
    protocol    = "tcp"

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp.load_balancer[0].target_group_id

    healthcheck {
      name                = "http"
      interval            = 10
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}