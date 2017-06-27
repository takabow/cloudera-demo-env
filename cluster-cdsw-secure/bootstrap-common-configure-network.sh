#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-common-configure-netowrk.log 2>&1
date

kerberos_hostname="kerberos"

# nmap
yum -y install nmap

# bind-utils
yum -y install bind-utils

# waiting for TCP 7 of CM server to open... 20 sec is enough?
sleep 20

if [ -e /root/cm ]; then
    hostname=$(hostname -s)
    internal_fqdn_suffix=$(hostname -d)
    hostname=$(hostname -s)
    internal_ip=$(hostname -i)
    netowrk_cidr=$(ipcalc -np "$(ip -o -f inet addr show | awk '/scope global/ {print $4}')" | awk '{getline x;print x;}1' | awk -F= '{print $2}' | awk 'NR%2{printf "%s/",$0;next;}1')
    
    # Add KDC hostname
    echo "${internal_ip}    ${hostname}.${internal_fqdn_suffix} ${hostname} ${kerberos_hostname}.${internal_fqdn_suffix} ${kerberos_hostname}" >> /etc/hosts
else
    # Looking for the CM node 
    netowrk_cidr=$(ipcalc -np "$(ip -o -f inet addr show | awk '/scope global/ {print $4}')" | awk '{getline x;print x;}1' | awk -F= '{print $2}' | awk 'NR%2{printf "%s/",$0;next;}1')
    cm_ip=$(nmap -sT -p7 ${netowrk_cidr} | grep -B 3 open | grep "ip-" | awk -F[\(\)] '{print $2}')    
    cm_fqdn=$(host ${cm_ip} | awk '{print $5}')
    cm_hostname=$(echo ${cm_fqdn} | awk -F. '{print $1}')
    internal_fqdn_suffix=$(hostname -d)
    
    # Add KDC hostname
    echo "${cm_ip}    ${cm_hostname}.${internal_fqdn_suffix} ${cm_hostname} ${kerberos_hostname}.${internal_fqdn_suffix} ${kerberos_hostname}" >> /etc/hosts
fi
