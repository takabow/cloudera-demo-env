#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cdsw-init.log 2>&1
date

# Worker node identifier
touch /root/cdsw

# Install Required Packages for CDSW 
yum -y install nfs-utils
yum -y install libseccomp
yum -y install lvm2
yum -y install bridge-utils
yum -y install libtool-ltdl
yum -y install iptables
yum -y install rsync
yum -y install policycoreutils-python
yum -y install selinux-policy-base
yum -y install selinux-policy-targeted
yum -y install ntp
yum -y install ebtables
yum -y install bind-utils
yum -y install nmap-ncat
yum -y install openssl
yum -y install e2fsprogs
yum -y install redhat-lsb-core
yum -y install socat

# Mount one volume for application data
device="/dev/xvdh"
mount="/var/lib/cdsw"

echo "Making file system"
mkfs.ext4 -F -E lazy_itable_init=1 "$device" -m 0

echo "Mounting $device on $mount"
if [ ! -e "$mount" ]; then
    mkdir -p "$mount"
fi

mount -o defaults,noatime "$device" "$mount"
echo "$device $mount ext4 defaults,noatime 0 0" >> /etc/fstab
