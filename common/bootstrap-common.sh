#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-common.log 2>&1
date

# Change localtime
# Modiy this with your Timezone
ln -sf  /usr/share/zoneinfo/Japan /etc/localtime

# JDK8 installation
yum remove --assumeyes *openjdk*
rpm -ivh "http://archive.cloudera.com/director/redhat/7/x86_64/director/2.5.0/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"
alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_121-cloudera/bin/java 1
ln -nfs /usr/java/jdk1.8.0_121-cloudera /usr/java/latest
ln -nfs /usr/java/latest /usr/java/default