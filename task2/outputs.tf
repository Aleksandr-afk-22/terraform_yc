output "picture_url" {
  description = "Публичная ссылка на картинку из бакета"
  value       = "https://storage.yandexcloud.net/${yandex_storage_bucket.site.bucket}/${yandex_storage_object.picture.key}"
}

output "target_group_id" {
  description = "ID target group Instance Group (для балансировщика на следующем шаге)"
  value       = yandex_compute_instance_group.lamp.load_balancer[0].target_group_id
}

output "ig_instances" {
  description = "Имя и публичный IP каждой ВМ группы"
  value = [
    for i in yandex_compute_instance_group.lamp.instances : {
      name = i.name
      ip   = i.network_interface[0].nat_ip_address
    }
  ]
}

output "nlb_ip" {
  description = "IP сетевого балансировщика"
  value       = tolist(tolist(yandex_lb_network_load_balancer.lamp_nlb.listener)[0].external_address_spec)[0].address
}
