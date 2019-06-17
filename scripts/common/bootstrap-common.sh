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
rpm -ivh "http://archive.cloudera.com/director6/6.0.0/redhat7/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update141-1.x86_64.rpm"

#Use ntpd instead of chrony
#And Use Amazon Time Sync Service mainly - https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/set-time.html
yum erase -y ntp
yum install -y chrony
sed -i -e '/^server/d' /etc/chrony.conf
echo "server 169.254.169.123 prefer iburst" >> /etc/chrony.conf
echo "server 169.254.169.254 iburst" >> /etc/chrony.conf
echo "server time.google.com iburst" >> /etc/chrony.conf
cat /etc/chrony.conf
service ntpd stop
systemctl stop chronyd
systemctl start chronyd
systemctl status chronyd

chronyc tracking
chronyc sources
chronyc sourcestats
