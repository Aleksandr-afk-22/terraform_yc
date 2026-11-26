output "nat_internal_ip" {
  description = "Внутренний IP NAT-инстанса"
  value       = yandex_compute_instance.nat.network_interface.0.ip_address
}

output "nat_external_ip" {
  description = "Публичный (ephemeral) IP NAT-инстанса"
  value       = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}

output "public_vm_external_ip" {
  description = "Публичный IP bastion-ВМ"
  value       = yandex_compute_instance.public.network_interface.0.nat_ip_address
}

output "public_vm_internal_ip" {
  description = "Внутренний IP bastion-ВМ"
  value       = yandex_compute_instance.public.network_interface.0.ip_address
}

output "private_vm_internal_ip" {
  description = "Внутренний IP приватной ВМ (доступен только через bastion)"
  value       = yandex_compute_instance.private.network_interface.0.ip_address
}