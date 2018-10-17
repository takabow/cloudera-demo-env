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
yum erase -y chrony
yum install -y ntp
cat /etc/ntp.conf
sed -i -e '/^server/d' /etc/ntp.conf
echo "server 169.254.169.123 prefer iburst" >> /etc/ntp.conf
#echo "server time.google.com iburst" >> /etc/ntp.conf
cat /etc/ntp.conf
service ntpd stop
service ntpd start
service ntpd status
chkconfig ntpd on
ntptime
ntpq -p
ntpq -n -c opeers
