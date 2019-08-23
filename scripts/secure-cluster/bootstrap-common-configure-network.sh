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
    netowrk_cidr=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
    
    # Add KDC hostname
    echo "${internal_ip}    ${hostname}.${internal_fqdn_suffix} ${hostname} ${kerberos_hostname}.${internal_fqdn_suffix} ${kerberos_hostname}" >> /etc/hosts
else
    # Looking for the CM node 
    netowrk_cidr=$(ip -o -f inet addr show | awk '/scope global/ {print $4}') 
    cidr_prefix_length=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | awk -F'/' '{print $2}') 

    if [ "${cidr_prefix_length}" -eq 32 ]; then #GCP
        network_addr=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | awk -F'/' '{print $1}')
        netowrk_cidr="${network_addr}/20" #/20 is default of GCP
    fi
    echo ${netowrk_cidr}
    
    for i in `seq 30` : # 30*10sec -> 5min
    do
        cm_fqdn=$(nmap -sT -p7 ${netowrk_cidr} | grep -B 3 open | grep "Nmap scan report for" | awk '{print $5}')

        if [ -n "${cm_fqdn}" ]; then
            echo "CM node found."
            cm_ip=$(host ${cm_fqdn} | awk '{print $4}')
            cm_hostname=$(echo ${cm_fqdn} | awk -F. '{print $1}')
            internal_fqdn_suffix=$(hostname -d)
    
            # Add KDC hostname
            echo "${cm_ip}    ${cm_hostname}.${internal_fqdn_suffix} ${cm_hostname} ${kerberos_hostname}.${internal_fqdn_suffix} ${kerberos_hostname}" >> /etc/hosts
            break
        fi
        
        echo "looking for the CM server host... waiting 10 seconds."
        sleep 10
    done
fi
