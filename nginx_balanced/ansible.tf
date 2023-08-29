resource "local_file" "inventory" {
  content = <<-DOC
[proxy]
${yandex_compute_instance.balance_nginx.network_interface.0.nat_ip_address}
[nginx_uwsgi]
${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address} 
${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address}  
[db]
${yandex_compute_instance.db.network_interface.0.ip_address}
[nginx_uwsgi:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@${yandex_compute_instance.balance_nginx.network_interface.0.nat_ip_address}"'
[db:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@${yandex_compute_instance.balance_nginx.network_interface.0.nat_ip_address}"'


    DOC
  filename = "../ansible/inventory.yaml"

  depends_on = [
    yandex_compute_instance.db
  ]
}

resource "local_file" "nginx_file"{
  content = <<-DOC
upstream backend {
	server ${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address};
	server ${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address};
}

server {
	listen 80;
	server_name ${yandex_compute_instance.balance_nginx.network_interface.0.nat_ip_address};
	
location / {
  proxy_pass http://backend;
	}
 }
    DOC
  filename = "default"

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 20"
  }

  depends_on = [
    local_file.nginx_file
  ]
}
resource "null_resource" "ansible_nginx" {
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i ../ansible/inventory.yaml ../ansible/nginx.yaml"
  }

  depends_on = [
    null_resource.wait
  ]
}
 resource "null_resource" "ansible_nginx_uwsgi" {
   provisioner "local-exec" {
     command = "git clone https://github.com/vk1391/ansible-nginx-uwsgi.git"
   }
   depends_on = [
     null_resource.ansible_nginx
   ]
 }
 resource "null_resource" "ansible_nginx_uwsgi_install" {
   provisioner "local-exec" {
     command = "ansible-playbook -u ubuntu -i ../ansible/inventory.yaml ansible-nginx-uwsgi/nginx-uwsgi.yml"
   }
   depends_on = [
     null_resource.ansible_nginx_uwsgi
   ]
 }