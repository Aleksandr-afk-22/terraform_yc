# ── Подключение к Yandex Cloud ────────────────────────────────
variable "yc_cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "yc_folder_id" {
  description = "ID каталога (folder) в Yandex Cloud"
  type        = string
}

variable "sa_key_file" {
  description = "Путь к ключу сервисного аккаунта (authorized_key.json)"
  type        = string
  sensitive   = true
}

variable "yc_zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

# ── Доступ по SSH ───────────────────────────────────────────
variable "ssh_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
}

variable "ssh_user" {
  description = "Пользователь для SSH-подключения"
  type        = string
  default     = "ubuntu"
}

# ── Сеть ────────────────────────────────────────────────────
variable "vpc_name" {
  description = "Имя VPC"
  type        = string
  default     = "netology-vpc"
}

variable "public_subnet_cidr" {
  description = "CIDR публичной подсети"
  type        = string
  default     = "192.168.10.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR приватной подсети"
  type        = string
  default     = "192.168.20.0/24"
}

variable "nat_ip" {
  description = "Внутренний IP NAT-инстанса"
  type        = string
  default     = "192.168.10.254"
}

# ── Образы ВМ ───────────────────────────────────────────────
variable "nat_image_id" {
  description = "ID образа NAT-инстанса (из задания)"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}

variable "vm_image_id" {
  description = "ID образа ОС для ВМ"
  type        = string
  default     = "fd806c8slu9j1pa87msc" 
}

variable "vm_web_preemptible" {
  description = "Прерываемые ВМ (true — экономия, false — стабильность)"
  type        = bool
  default     = true
}
