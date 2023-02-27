#!/bin/bash
WINDOWSIP="172.16.150.50"
JUMPUSER="jump-paul"
JUMPIP="172.16.50.4"

sftp paul@WINDOWSIP:ssh-keys.pub
scp ssh-keys.pub paul@JUMPIP:travel.pub

ssh paul@JUMPIP <<END
  sudo -i
  cat /home/paul/travel.pub >> /home/$JUMPUSER/.ssh/authorized_keys
END
