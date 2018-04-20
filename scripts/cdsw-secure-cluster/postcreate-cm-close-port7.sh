#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/postcreate-cm-close-port7.log 2>&1
date

# Stop ECHO Server (on TCP port 7)
# This ECHO Server was for CM node discovery in the bootstrapping.
systemctl stop xinetd
systemctl status xinetd
perl -pi -e "s/(disable.*=.*)no/\1yes/" /etc/xinetd.d/echo-stream
