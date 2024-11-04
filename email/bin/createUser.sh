#!/bin/bash
USER=$2
NAME="$1"
VIRTUAL=/etc/postfix/virtual
HOSTNAME=`hostname`
sudo useradd -m -c "$NAME" -s /usr/sbin/nologin $USER
sudo passwd $USER
case $HOSTNAME in 
  dtn1)
    echo "$USER@earth.viagenie.ca	$USER" > $VIRTUAL
    postmap $VIRTUAL
    ;;

  dtn2)
    echo "$USER@mars.viagenie.ca	$USER" > $VIRTUAL
    postmap $VIRTUAL
    ;;

esac

