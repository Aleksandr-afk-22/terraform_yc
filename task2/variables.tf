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
  description = "Пользователь для SSH"
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

# ── Object Storage ──────────────────────────────────────────
variable "bucket_name" {
  description = "Имя бакета (глобально уникально во всём Object Storage)"
  type        = string
}

variable "picture_path" {
  description = "Путь к локальному файлу картинки для загрузки в бакет"
  type        = string
}

# ── Виртуальные машины (Instance Group) ─────────────────────
variable "lamp_image_id" {
  description = "ID образа LAMP (из задания)"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}

variable "vm_web_preemptible" {
  description = "Прерываемые ВМ"
  type        = bool
  default     = true
}

variable "ig_size" {
  description = "Размер Instance Group (фиксированный)"
  type        = number
  default     = 3
}

variable "storage_access_key" {
  description = "Static access key для Object Storage (S3-совместимый API)"
  type        = string
  sensitive   = true
}

variable "storage_secret_key" {
  description = "Secret key для Object Storage"
  type        = string
  sensitive   = true
}
