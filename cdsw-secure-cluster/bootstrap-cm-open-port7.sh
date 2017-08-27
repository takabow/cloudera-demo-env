#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cm-open-port7.log 2>&1
date

# Setting ECHO Server (on TCP port 7)
# Open the TCP port 7 so that other nodes can identify the CM node in the bootstrapping.
# If the TCP port 7 is opened, the node must be the CM node.
yum -y install xinetd
yum -y install perl
perl -pi -e "s/(disable.*=.*)yes/\1no\n\tflags           = IPv4/" /etc/xinetd.d/echo-stream
systemctl restart xinetd
systemctl status xinetd
netstat -anpt | grep xinetd
