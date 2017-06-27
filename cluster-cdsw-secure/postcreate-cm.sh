#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/postcreate-cm.log 2>&1
date

# Stop ECHO Server (on TCP port 7)
# This ECHO Server was for CM node discovery in the bootstrapping.
systemctl stop xinetd
sed -i -e "s:\(disable.*=.*\)no:\1yes:" /etc/xinetd.d/echo-stream