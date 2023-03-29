#!/bin/bash

# Sources:
https://www.wireguard.com/quickstart/
https://askubuntu.com/questions/906325/ubuntu-iptables-nat-router-port-forwarding
https://superuser.com/questions/269980/iptables-for-transparent-tcp-proxy


# Prompt user to enter the name of their main Ethernet adapter
read -p "Enter the name of your main Ethernet adapter: " adapter_name

# Install WireGuard
sudo apt update
sudo apt install wireguard -y
sudo umask 077
sudo mkdir -p /etc/wireguard/

# Keygen
sudo wg genkey | sudo tee /etc/wireguard/privatekey-server | wg pubkey | sudo tee /etc/wireguard/publickey-server
sudo wg genkey | sudo tee /etc/wireguard/privatekey-client | wg pubkey | sudo tee /etc/wireguard/publickey-client

# Generate server configuration file
sudo touch /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf
sudo tee -a /etc/wireguard/wg0.conf << END
[Interface]
Address = 10.0.0.1/24
SaveConfig = true
PrivateKey = $(sudo cat /etc/wireguard/privatekey-server)
ListenPort = 51820

PreUp = sysctl -w net.ipv4.ip_forward=1
PreUp = iptables -t nat -A PREROUTING -p tcp -d 10.0.0.1 --dport 3389 -j DNAT --to-destination 172.16.200.11:3389
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $adapter_name -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $adapter_name -j MASQUERADE
PostDown = iptables -t nat -D PREROUTING -p tcp -d 10.0.0.1 --dport 3389 -j DNAT --to-destination 172.16.200.11:3389

[Peer]
PublicKey = $(sudo cat /etc/wireguard/publickey-client)
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
END

# Generate client configuration file
sudo mkdir -p /etc/wireguard/clients/
sudo tee /etc/wireguard/clients/client1-GCorp.conf << END
[Interface]
Address = 10.0.0.2/32
PrivateKey = $(sudo cat /etc/wireguard/privatekey-client)

[Peer]
PublicKey = $(sudo cat /etc/wireguard/publickey-server)
Endpoint = 10.0.17.127:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
END

# Restart WireGuard service
sudo systemctl restart wg-quick@wg0.service
