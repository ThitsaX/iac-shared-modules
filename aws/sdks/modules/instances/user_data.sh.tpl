#!/usr/bin/bash
apt-get install -y ${packages}
curl -fsSL https://get.docker.com | bash
usermod -a -G docker ubuntu
echo "${nameserver}" >> /etc/resolv.conf
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose