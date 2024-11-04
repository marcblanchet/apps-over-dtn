# Configuration for HTTP over DTN
The setup is two linux servers (VM or else), named dtn1.viagenie.ca and dtn2.viagenie.ca (modify as you see fit) and a BP network (of any size, length or topology) in between. The two servers act as http proxies. One side sending the HTTP request, put in a payload and send to the other side that extract it from the payload, executes curl on that request to the network on the other side and sends back the response by encapsulating it into a returned bundle which is then extracted at the source end and printed on the stdout which is then relayed to the nginx/FastCGI process.

Caution: we try to put any path relative to some vars and only have some defaults at the top of the scripts file, you should look at them and modify based on your installation.

This document may not be complete, so please submit PR or issues so that we can enhance it.

## Initial Configuration
### ud3tn
- git clone https://gitlab.com/d3tn/ud3tn
- cd ud3tn
- git submodule init && git submodule update
- make run-posix

### FastCGI
- install nginx and fastCGI. doc TBD

# Our scripts
* bin/httpToDTN.sh
  * receives http request as a fastcgi with env variables, forward it to the ud3tn agent to be encapsulated over BP to the other server which will do an http client request on the other side and return result to here.
* bin/dtnTohttp.sh
  * receives http request in a bundle (format is: "GET http://example.org HTTP/1.1), executes the request using curl, sends the received payload back to the sender.


