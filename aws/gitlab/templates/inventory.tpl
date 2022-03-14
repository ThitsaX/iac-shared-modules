[all]
gitlab_server ansible_host=${gitlab_server_hostname}
gitlab_ci ansible_host=${gitlab_ci_hostname}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_user=${ssh_user}
ansible_ssh_private_key_file=${ssh_key}
smtp_server_enable=${smtp_server_enable}
smtp_server_address='${smtp_server_address}'
smtp_server_port=${smtp_server_port}
smtp_server_user=${smtp_server_user}
smtp_server_pw=${smtp_server_pw}
smtp_server_mail_domain=${smtp_server_mail_domain}
enable_github_oauth=${enable_github_oauth}
github_oauth_id=${github_oauth_id}
github_oauth_secret=${github_oauth_secret}
letsencrypt_endpoint='${letsencrypt_endpoint}'
server_password=${server_password}
server_token=${server_token}
external_url='${external_url}'
server_hostname=${server_hostname}
enable_pages=${enable_pages}
gitlab_version=${gitlab_version}