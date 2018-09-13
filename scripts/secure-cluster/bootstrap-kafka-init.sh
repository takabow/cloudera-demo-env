#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-kafka-init.log 2>&1
date

# Worker node identifier
touch /root/kafka
