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
rpm -ivh "http://archive.cloudera.com/director/redhat/7/x86_64/director/2.8.0/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"
JAVA_HOME="oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"
alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1
alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1
ln -nfs /usr/java/jdk1.8.0_121-cloudera /usr/java/latest
ln -nfs /usr/java/latest /usr/java/default

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
