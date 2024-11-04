#!/bin/bash
#
# receives http request as a fastcgi with env variables
# forward it to the ud3tn agent to be encapsulated over BP
# to the other server which will do an http client request
# on the other side and return result to here.
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
BPPAYLOAD="$REQUEST_METHOD $REQUEST_SCHEME://$HTTP_HOST$REQUEST_URI $SERVER_PROTOCOL"

cd $UD3TN
source .venv/bin/activate
RECEIVEDFILE=/tmp/`uuid`.receivedfile.txt
echo $BPPAYLOD | python tools/aap/aap_send_and_receive.py -c 1 --tcp $AAPIP $AAPPORT -a $AGENTID -o $RECEIVEDFILE $DESTINATIONEID
#cat $RECEIVEDFILE 
#rm $RECEIVEDFILE
cat <<EOF
Content-type: text/html

<html>
<pre>
EOF
cat $RECEIVEDFILE
cat <<EOF2
</pre>
</html>
EOF2
exit 0
