#!/bin/bash
WINDOWSUSER="paul"
WINDOWSIP="10.0.17.27"
JUMPUSER="paul-jump"
JUMPIP="172.16.50.4"

sftp $WINDOWSUSER@$WINDOWSIP:ssh-keys.pub
scp ssh-keys.pub paul@$JUMPIP:travel.pub

ssh paul@$JUMPIP <<END
  sudo -i
  cat /home/paul/travel.pub >> /home/$JUMPUSER/.ssh/authorized_keys
END
