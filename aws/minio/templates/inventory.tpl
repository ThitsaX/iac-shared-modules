[all]
minio ansible_host=${minio_hostname}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_user=${ssh_user}
ansible_ssh_private_key_file=${ssh_key}