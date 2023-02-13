#!/bin/bash

network=$1
name_serv=$2

echo "dns resolution for $network"
for ((ip=1; ip<=254; ip++)); do
   ipaddr="$1.$ip"
   nslookup $ipaddr $name_serv | grep name
done
