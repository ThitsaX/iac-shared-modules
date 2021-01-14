#!/bin/sh

if [ $# -ne 4 ]; then 
	echo "illegal number of parameters"
        echo "Usage: create_user <ID> <DNS_SERVER> <SERVER_ADDRESS> <Description>"
        exit 1
fi


if [ -f /etc/wireguard/client_$ID.profile ]; then
  echo "Profile already exists. Skipping creation."
  exit 0
fi

ID=$1
DNS=$2
SERVER_ADDRESS=$3
COMMENT=$4

umask 077
wg genkey | tee /etc/wireguard/client_$ID.key | wg pubkey  | tee /etc/wireguard/client_$ID.pub
systemctl stop wg-quick@wg0

cat <<EOF > /etc/wireguard/client_$ID.profile
# $COMMENT
[Interface]
PrivateKey =  $(cat /etc/wireguard/client_$ID.key)
Address = 192.168.100.$(($ID+1))
DNS = $DNS

[Peer]
PublicKey = $(cat  /etc/wireguard/publickey)
AllowedIPs = 0.0.0.0/0
Endpoint = $SERVER_ADDRESS
PersistentKeepalive = 25
EOF

cat <<EOF | tee -a /etc/wireguard/wg0.conf

# $COMMENT
[Peer]
PublicKey = $(cat /etc/wireguard/client_$ID.pub)
AllowedIPs = 192.168.100.$(($ID+1))/32 
EOF

# Make sure the wireguard module has been loaded in the kernel
if [ $(lsmod | grep wireguard | wc -l ) -lt 1 ]; then echo "Didn't find wireguard kernel module, reboot server to start wireguard"; fi

#systemctl start wg-quick@wg0

