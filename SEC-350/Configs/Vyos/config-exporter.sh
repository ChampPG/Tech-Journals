#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
run show configuration commands | grep -v "syslog\|ntp\|login\|console\|config\|hw-id\|loopback\|conntrack"
