#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cm-init.log 2>&1
date

# CM node identifier
touch /root/cm
