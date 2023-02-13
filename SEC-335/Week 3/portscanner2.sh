#!/bin/bash

network=$1
port=$2

echo "host,port"
for ((ip=1; ip<=254; ip++)); do
   ipaddr="$1.$ip"
   timeout .1 bash -c "echo >/dev/tcp/$ipaddr/$port" 2>/dev/null && echo "$ipaddr,$port"
done
