#!/bin/bash

sudo apt-get install nginx -y

sudo unlink /etc/nginx/sites/enabled/default
cd /etc/nginx/sites-available/
touch SEC350.conf

/bin/cat << EOM >SEC350.conf
http {
    server {
       location / {
        root /data/www;
      }
    }
}
EOM

ln -s /etc/nginx/sites-available/SEC350.conf /etc/nginx/sites-enabled/SEC350.conf

cd /data/www/
touch index.html

/bin/cat << EOM >index.html
  Paul Gleason nginx
EOM
