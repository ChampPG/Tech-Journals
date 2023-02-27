#!/bin/bash

sudo apt install nginx -y

cd /var/www/html
touch index.html

/bin/cat << EOM >index.html
  Paul Gleason nginx
EOM

sudo systemctl start nginx
sudo systemctl enable nginx
