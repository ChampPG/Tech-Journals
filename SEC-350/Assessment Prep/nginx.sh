#!/bin/bash

sudo apt-get install nginx -y

sudo unlink /etc/nginx/sites/enabled/default
cd /etc/nginx/sites-available/
touch SEC350.conf
curl https://raw.githubusercontent.com/ChampPG/Tech-Journals/main/SEC-350/Assessment%20Prep/nginx.conf > SEC350.conf
ln -s /etc/nginx/sites-available/SEC350.conf /etc/nginx/sites-enabled/SEC350.conf

cd /data/www/
touch index.html

/bin/cat << EOM >$FILE
  Paul Gleason nginx
EOM
