#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cdsw-init.log 2>&1
date

# Worker node identifier
touch /root/cdsw

cd /etc/yum.repos.d
curl -Os https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/cloudera-cdsw.repo
rpm --import https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/RPM-GPG-KEY-cloudera
yum install -y cloudera-data-science-workbench
