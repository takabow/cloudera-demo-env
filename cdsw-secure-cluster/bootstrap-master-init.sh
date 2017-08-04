#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-master-init.log 2>&1
date

# Master node identifier
touch /root/master
