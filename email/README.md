# Configuration for Email over DTN
The setup is two linux servers (VM or else), named dtn1.viagenie.ca and dtn2.viagenie.ca (modify as you see fit) and a BP network (of any size, length or topology) in between. [Postfix](http://www.postfix.org) is used as the SMTP server and [Dovecot](https://www.dovecot.org) as the IMAP Server. [ud3tn](https://gitlab.com/d3tn/ud3tn) is used for Bundle Protocol. DNS MX records were used for proper handling: one would send email to userX@dtn2.viagenie.ca. 

Caution: we try to put any path relative to some vars and only have some defaults at the top of the scripts file, you should look at them and modify based on your installation.

This document may not be complete, so please submit PR or issues so that we can enhance it.

## Initial Configuration
### Postfix
- apt install postfix
- files changed in the repo for both nodes: 
	- [dtn1/main.cf](dtn1/main.cf), [dtn1/virtual](dtn1/virtual), [dtn1/master.cf](dtn1/master.cf), [dtn1:/etc/aliases](dtn1/aliases)
	- [dtn2/main.cf](dtn2/main.cf), [dtn2/virtual](dtn2/virtual), [dtn2/master.cf](dtn2/master.cf), [dtn2:/etc/aliases](dtn2/aliases)
- postmap virtual; newaliases
- systemctl restart postfix
- systemctl enable postfix

### Dovecot
- apt install dovecot-imapd
- systemctl enable dovecot
- systemctl start dovecot

### ud3tn
- git clone https://gitlab.com/d3tn/ud3tn
- cd ud3tn
- git submodule init && git submodule update
- make run-posix

# Our scripts
* bin/startDTN.sh
  * Starts the DTN BP agent and starts the emailOverDTN.sh to receive emails from the BP network
* bin/emailOverDTN.sh
  * process emails received from/or to be sent to the BP network

# Run
* on dtn1.viagenie.ca:
  * ./startDTN.sh -e dtn://earth.ssi/ -c mtcp:dtn2.viagenie.ca:4222 -n dtn://mars.ssi
* on dtn2.viagenie.ca:
  * ./startDTN.sh -e dtn://mars.ssi/ -c mtcp:dtn1.viagenie.ca:4222 -n dtn://earth.ssi


