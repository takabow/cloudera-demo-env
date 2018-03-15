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
    
    for i in `seq 30` : # 30*10sec -> 5min
    do
        cm_ip=$(nmap -sT -p7 ${netowrk_cidr} | grep -B 3 open | grep "ip-" | awk -F[\(\)] '{print $2}')

        if [ -n "${cm_ip}" ]; then
            echo "CM node found."
            cm_fqdn=$(host ${cm_ip} | awk '{print $5}')
            cm_hostname=$(echo ${cm_fqdn} | awk -F. '{print $1}')
            internal_fqdn_suffix=$(hostname -d)
    
            break
        fi
        
        echo "looking for the CM server host... waiting 10 seconds."
        sleep 10
    done
fi
