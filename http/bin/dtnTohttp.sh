#!/bin/bash
#
# receives http request in a bundle
# format is: "GET http://example.org HTTP/1.1
# executes the request using curl
# send the received payload back to the sender
#
# Marc Blanchet, marc.blanchet@viagenie.ca
# @Copyright 2023
#
# defaults if not specified
AGENTID="http"
DESTINATIONEID="dtn://mars.ssi/$AGENTID"
#
UD3TN="/home/blanchet/ud3tn"
AAPIP="localhost"
AAPPORT=4242
UUID=`uuid`
TMPFILE=/tmp/$UUID.send.txt

cd $UD3TN
source .venv/bin/activate
RECEIVEDFILE=/tmp/`uuid`.receivedfile.txt
python tools/aap/aap_receive.py -c 1 --tcp $AAPIP $AAPPORT -a $AGENTID -o $RECEIVEDFILE
HTTPMETHOD=`cat $RECEIVEDFILE | awk '{print $1}'`
HTTPURI=`cat $RECEIVEDFILE | awk '{print $2}'`
HTTPVERSION=`cat $RECEIVEDFILE | awk '{print $3}'`
curl -s -i -X $HTTPMETHOD $HTTPURI > $TMPFILE
cat $TMPFILE | python tools/aap/aap_send.py -c 1 --tcp $AAPIP $AAPPORT $DESTINATIONEID
