
# ansible inventory
resource "local_file" "inventory" {
  filename        = "../ansible/inventory.ini"
  file_permission = "0660"
  content         = <<EOF
[proxy]
${aws_instance.proxy.public_ip}
[proxy:vars]
ansible_user = admin
ansible_ssh_private_key_file = ${var.ssh_key_file}

[web]
${aws_instance.web[0].private_ip}
${aws_instance.web[1].private_ip}
[web:vars]
ansible_user = admin
ansible_ssh_private_key_file = ${var.ssh_key_file}
ansible_ssh_common_args='-o ProxyCommand="ssh -i ${var.ssh_key_file} -W %h:%p -q admin@${aws_instance.proxy.public_ip}"'
nfs_wp_content_ip = ${aws_efs_mount_target.private_subnet.ip_address}:/

[db]
${aws_instance.db.private_ip}
[db:vars]
ansible_user = admin
ansible_ssh_private_key_file = ${var.ssh_key_file}
ansible_ssh_common_args='-o ProxyCommand="ssh -i ${var.ssh_key_file} -W %h:%p -q admin@${aws_instance.proxy.public_ip}"'
EOF
}
