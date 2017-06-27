#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-common.log 2>&1
date

# Change localtime
# Modiy this with your Timezone
ln -sf  /usr/share/zoneinfo/Japan /etc/localtime
