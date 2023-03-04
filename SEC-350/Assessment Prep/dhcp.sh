sudo apt update
sudo apt install isc-dhcp-server -y

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup

FILE="/etc/dhcp/dhcpd.conf"
/bin/cat << EOM >$FILE
subnet 172.16.150.0 netmask 255.255.255.0 {
    option routers 172.16.150.2;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 172.16.150.2;
    range 172.16.150.100 172.16.150.150;
    default-lease-time 3600;
    max-lease-time 14400;
}
EOM

systemctl enable dhcpd
systemctl start dhcpd
systemctl status dhcpd
