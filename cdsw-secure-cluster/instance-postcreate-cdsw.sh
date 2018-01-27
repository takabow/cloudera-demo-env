#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/instance-postcreate-cdsw.log 2>&1
date

# Check CDSW node identifier set by bootstrap-cdsw-init.sh
if [ ! -e /root/cdsw ]; then
echo "This is not a cdsw node."
exit 0
fi

# install CDSW
cd /etc/yum.repos.d
cat << __EOF__ > cloudera-cdsw.repo
[cloudera-cdsw]
name=Cloudera's Distribution for cdsw, Version 1
baseurl=https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/1.3.0/
gpgkey =https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/RPM-GPG-KEY-cloudera
gpgcheck = 1
__EOF__
rpm --import https://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/RPM-GPG-KEY-cloudera
yum install -y cloudera-data-science-workbench

cd /root

# install git
yum -y install git

# install dnsmasq
yum -y install dnsmasq
cat /etc/resolv.conf | grep nameserver > /etc/dnsmasq.resolv.conf
perl -pi -e "s|^.*?resolv-file.*?$|resolv-file=/etc/dnsmasq.resolv.conf|" /etc/dnsmasq.conf
systemctl start dnsmasq

# Add DNS(dnsmasq on local)
perl -pi -e "s/nameserver.*$/nameserver $(hostname -i)/" /etc/resolv.conf
chattr +i /etc/resolv.conf 

# This domain for DNS and is unrelated to Kerberos or LDAP domains.
DOMAIN="cdsw.$(hostname -i).xip.io"

# IPv4 address for the master node that is reachable from the worker nodes.
#
# Within an AWS VPC, MASTER_IP should be set to the internal IP
# of the master node; for instance, "10.251.50.12" corresponding to
# master node name of ip-10-251-50-12.ec2.internal.
MASTER_IP=$(hostname -i)

# Block device(s) for Docker images (space separated if multiple).
#
# These block devices cannot be partitions and should be at least 500GB. SSDs
# are strongly recommended.
#
# Use the full path, for instance "/dev/xvde".
DOCKER_BLOCK_DEVICES="$(grep '^/dev' /etc/fstab | cut -f1 -d' ' | sort | tail -n +2 | tr '\n' ' ')"

# (Not recommended, Master Only) One Block device for application state.
#
# If omitted, the filesystem mounted at /var/lib/cdsw on the master node
# will be used to store all user data. Cloudera *strongly* recommends
# that you mount a high reliability filesystem with backups configured.
# See the Cloudera Data Science Workbench documentation for sizing
# recommendations.
#
# If set, Cloudera Data Science Workbench will format the provided block
# device as ext4, mount it to /var/lib/cdsw and store all user data on it.
# This block device should be at least 500GB, and potentially significantly
# larger to scale with the number of projects expected.  An SSD is strongly
# recommended. This option is provided for convenience in demonstration or
# evaluation setups only, Cloudera is not responsible for data loss.
#
# Use the full path, for instance "/dev/xvdf".
APPLICATION_BLOCK_DEVICE="$(grep '^/dev' /etc/fstab | cut -f1 -d' ' | sort | head -1)"

# e.g.)
# cat /etc/fstab 
# ...
# /dev/xvdi /data0 ext4 defaults,noatime 0 0
# /dev/xvdh /data1 ext4 defaults,noatime 0 0
# /dev/xvdg /data2 ext4 defaults,noatime 0 0
# /dev/xvdf /data3 ext4 defaults,noatime 0 0
# 
# $(grep '^/dev' /etc/fstab | cut -f1 -d' ' | sort | head -1) command gets "/dev/xvdf"
# $(grep '^/dev' /etc/fstab | cut -f1 -d' ' | sort | tail -n +2 | tr '\n' ' ') command gets "/dev/xvdg /dev/xvdh /dev/xvdi"

# Path where Java is installed on the CDSW nodes, eg /usr/java/default
# Please consult Cloudera documentation for CDH and Cloudera Manager's
# supported JDK versions.
JAVA_HOME_CANDIDATES=(
    '/usr/java/jdk1.8'
    '/usr/java/jre1.8'
    '/usr/lib/jvm/j2sdk1.8-oracle'
    '/usr/lib/jvm/j2sdk1.8-oracle/jre'
    '/usr/lib/jvm/java-8-oracle'
    '/usr/lib/jdk8-latest'
    '/usr/java/jdk1.7'
    '/usr/java/jre1.7'
    '/usr/lib/jvm/j2sdk1.7-oracle'
    '/usr/lib/jvm/j2sdk1.7-oracle/jre'
    '/usr/lib/jvm/java-7-oracle'
    '/usr/lib/jdk7-latest'
)
echo $JAVA_HOME
if [ -z "${JAVA_HOME}" ]; then
  for candidate_regex in ${JAVA_HOME_CANDIDATES[@]} ; do
      for candidate in `ls -rvd ${candidate_regex}* 2>/dev/null`; do
        if [ -e ${candidate}/bin/java ]; then
          export JAVA_HOME=${candidate}
          echo $JAVA_HOME
          break
        fi
      done
  done
fi


# Configuring /etc/cdsw/config/cdsw.conf
perl -pi -e "s/DOMAIN=.*/DOMAIN=\"${DOMAIN}\"/" /etc/cdsw/config/cdsw.conf
perl -pi -e "s/MASTER_IP=.*/MASTER_IP=\"${MASTER_IP}\"/" /etc/cdsw/config/cdsw.conf
perl -pi -e "s|DOCKER_BLOCK_DEVICES=.*|DOCKER_BLOCK_DEVICES=\"${DOCKER_BLOCK_DEVICES}\"|" /etc/cdsw/config/cdsw.conf
perl -pi -e "s|APPLICATION_BLOCK_DEVICE=.*|APPLICATION_BLOCK_DEVICE=\"${APPLICATION_BLOCK_DEVICE}\"|" /etc/cdsw/config/cdsw.conf
perl -pi -e "s|JAVA_HOME=.*|JAVA_HOME=\"${JAVA_HOME}\"|" /etc/cdsw/config/cdsw.conf
for dev in $(grep '^/dev' /etc/fstab | cut -f1 -d' '); do umount $dev; done
sed -i '/^\/dev/d' /etc/fstab

# cdsw init - preinstall-validation - doesn't allow SELinux "permissive"
perl -pi -e "s/getenforce/#getenforce/" /etc/cdsw/scripts/preinstall-validation.sh
perl -pi -e "s/SELINUX=.*/SELINUX=disabled/" /etc/selinux/config

# cdsw init - preinstall-validation - doesn't allow IPv6
echo "net.ipv6.conf.all.disable_ipv6=0" >> /etc/sysctl.conf

# Cloudera Data Science Workbench recommends that all users have a max-open-files limit set to 1048576.
ulimit -n 1048576
echo "* soft nofile 1048576" >> /etc/security/limits.conf
echo "* hard nofile 1048576" >> /etc/security/limits.conf

# Re-enabling iptables. Cloudera Director disables iptables but K8s needs it.
rm -rf /etc/modprobe.d/iptables-blacklist.conf
modprobe iptable_filter

# CDSW init
echo | cdsw init

# Waiting for CDSW is up
for i in `seq 30` : # 30*10sec -> 5min
do
    cdsw status
    if [ $? -eq 0 ]; then
        echo "CDSW is now up and ready."
        break
    fi
    echo "Waiting for CDSW is up.... 10 seconds."
    sleep 10
done
