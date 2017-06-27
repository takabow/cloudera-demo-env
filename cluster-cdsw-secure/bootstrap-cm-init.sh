#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cm-init.log 2>&1
date

# CM node identifier
touch /root/cm

# Setting ECHO Server (on TCP port 7)
# Open the TPC port 7 so that other nodes can identify the CM node in the bootstrapping.
# If the TCP port 7 is opened, the node must be the CM node.
yum -y install xinetd
sed -i -e "s:\(disable.*=.*\)yes:\1no:" /etc/xinetd.d/echo-stream
systemctl start xinetd