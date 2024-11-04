#!/bin/bash
# forward/receive email over DTN using ud3tn bundle protocol stack
# 
# receives emails from stdin  (from postfix for example)
# forward it to the ud3tn agent to be encapsulated over BP
# to the other email server on the other end of the BP network
#
# receives emails from ud3tn agent decapsulated from bundle
# forward it to sendmail for local delivery
#
# Marc Blanchet, marc.blanchet@viagenie.ca
# @Copyright 2023
#
# defaults if not specified
MODE="receive"
AGENTID="email"
DESTINATIONEID="dtn://mars.ssi/$AGENTID"
#
UD3TN="/home/blanchet/ud3tn"
SENDMAIL="/usr/sbin/sendmail -bm -t"
AAPIP="localhost"
AAPPORT=4242
UUID=`uuid`
TMPFILE=/tmp/$UUID.send.txt

while getopts hm:d:a: option
do
  case "${option}" in
    h) echo "usage: -m receive|send -d destinationeid -a agentid"; exit;;
    m) MODE="${OPTARG}";;
    d) DESTINATIONEID="${OPTARG}";;
    a) AGENTID="${OPTARG}";;
  esac
done
cd $UD3TN
source .venv/bin/activate
case $MODE in
  receive) 
    # we need to loop as aap_receive just always write to the same file
    while :
    do
      RECEIVEDFILE=/tmp/`uuid`.receivedfile.txt
      python tools/aap/aap_receive.py -c 1 --tcp $AAPIP $AAPPORT -a $AGENTID -o $RECEIVEDFILE
      echo "email bundle received. delivering it"
      cat $RECEIVEDFILE | $SENDMAIL
      rm $RECEIVEDFILE
    done
    ;;
  send)
    python tools/aap/aap_send.py -v --tcp $AAPIP $AAPPORT $DESTINATIONEID
    ;;
esac
