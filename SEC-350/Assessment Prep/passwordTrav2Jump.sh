#!/bin/bash

JUMPUSER="jump-paul"

sftp paul@172.16.150.50:ssh-keys.pub
scp ssh-keys.pub paul@172.16.50.3:travel.pub

ssh paul@172.16.150.3 <<END
  cat travel.pub >> /home/$JUMPUSER/.ssh/authorized_keys
END
