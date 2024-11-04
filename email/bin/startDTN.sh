#!/bin/bash
# Starts DTN stack using ud3tn and configures it properly
#
# the EID that describes me
#"dtn://earth.ssi"
MYEID=""
# the EID of my neighbor I have BP connectivity with
#"dtn://mars.ssi"
NEIGHBOREID="" 
# the CLA address of my neighbor I have BP connectivity with
#"mtcp:dtn2.viagenie.ca:4222"
NEIGHBORCLA="" 
# the EID of a "far" node that is reachable through my neighbor
REACHINGEID=""
# the ud3tn application agent IP and port of my node stack
AAPIP="127.0.0.1"
AAPPORT="4242"
LOG=/tmp/`uuid`
LOGUD3TN=$LOG.ud3tn.txt
LOGCONFIG=$LOG.config.txt
LOGRECEIVE=$LOG.receive.txt
# duration of the contact to my neighbor: 604800 = 1 week
CONTACTDURATION=604800
# bandwidth between me and my neighbor
BANDWIDTH=1000000000
MYHOME=/home/blanchet
MYHOMEBIN=$MYHOME/bin
EMAILOVERDTN=$MYHOMEBIN/emailOverDTN.sh
EMAILAGENTID="email"
UD3TN=$MYHOME/ud3tn
UD3TNEXEC=$UD3TN/build/posix/ud3tn
USAGE="usage: -e myeid -n neighborEID -c neighborCLAAddressPort -r reachingNodeEID"

while getopts he:c:n:r: option
do
  case "${option}" in
    h) echo $USAGE; exit;;
    e) MYEID="${OPTARG}";;
    c) NEIGHBORCLA="${OPTARG}";;
    n) NEIGHBOREID="${OPTARG}";;
    r) REACHINGEID="-r ${OPTARG}";;
  esac
done
if [[ $MYEID == "" ]] || [[ $NEIGHBORCLA == "" ]] || [[ $NEIGHBOREID == "" ]]; then echo $USAGE; exit; fi
echo "make sure to have started postfix and dovecot"
echo "logs in $LOG.*"
result=$(netstat -t -l -4 | grep smtp > /dev/null)
result2=$(netstat -t -l -4 | grep imap > /dev/null)
if [[ $result -ne 0 ]] || [[ $result2 -ne 0 ]]; then 
   echo "no smtp or imap server running. want to continue, press return, else ctrl-C"
   read dontcare
fi
cd $UD3TN
source .venv/bin/activate
echo "starting BP stack"
$UD3TNEXEC -a $AAPIP -p $AAPPORT -e $MYEID >> $LOGUD3TN &
echo "press return when neighbor $NEIGHBOREID is started"
read dontcare
# send it its neighbor route
echo "registering a route to the neighbor"
python tools/aap/aap_config.py --tcp $AAPIP $AAPPORT -s 1 $CONTACTDURATION $BANDWIDTH $NEIGHBOREID $NEIGHBORCLA
# wait for receiving bundles for email
echo "waiting to receive a bundle for $EMAILAGENTID"
$EMAILOVERDTN -m receive -a $EMAILAGENTID
