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

# https://www.cloudera.com/documentation/data-science-workbench/latest/topics/cdsw_requirements_supported_versions.html
# Disable all pre-existing iptables rules. While Kubernetes makes extensive use of iptables, it’s difficult to predict how pre-existing iptables rules will interact with the rules inserted by Kubernetes. Therefore, Cloudera recommends you use the following commands to disable all pre-existing rules before you proceed with the installation.
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X

# This does not work here. Move to another script.
# `cdsw validate` command gives a warning when ipv6 is disabled.
#sudo sed -i "s/net.ipv6.conf.all.disable_ipv6=1/net.ipv6.conf.all.disable_ipv6=0/" /etc/sysctl.conf
#sudo sysctl -p

# It is not mandatory but for better performance to have a separate partition for /va/lib/cdsw.
# As I found that hard-coded block device path could cause a problem because it is named by AWS, I comment out this section.
#
# Mount one volume for application data
#device="/dev/xvdh"
#mount="/var/lib/cdsw"
#
#echo "Making file system"
#mkfs.ext4 -F -E lazy_itable_init=1 "$device" -m 0
#
#echo "Mounting $device on $mount"
#if [ ! -e "$mount" ]; then
#    mkdir -p "$mount"
#fi
#
#mount -o defaults,noatime "$device" "$mount"
#echo "$device $mount ext4 defaults,noatime 0 0" >> /etc/fstab
