output "external_ip_address_balance_nginx" {
  value = "${yandex_compute_instance.balance_nginx.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_balance_nginx" {
  value = "${yandex_compute_instance.balance_nginx.network_interface.0.ip_address}"
}
output "internal_ip_address_backend1_nginx" {
  value = "${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address}"
}
output "internal_ip_address_backend2_nginx" {
  value = "${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address}"
}
output "internal_ip_address_db" {
  value = "${yandex_compute_instance.db.network_interface.0.ip_address}"
}