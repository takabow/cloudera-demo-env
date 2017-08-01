#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cdsw-init.log 2>&1
date

# Worker node identifier
touch /root/cdsw

cd /etc/yum.repos.d
cat << __EOF__ > cloudera-cdsw.repo
[cloudera-cdsw]
# Packages for Cloudera's Distribution for data science workbench, Version 1, on RedHat	or CentOS 7 x86_64
name=Cloudera's Distribution for cdsw, Version 1
baseurl=https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/1.1.0/
gpgkey =https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/RPM-GPG-KEY-cloudera
gpgcheck = 1
__EOF__
rpm --import https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/RPM-GPG-KEY-cloudera
yum install -y cloudera-data-science-workbench
