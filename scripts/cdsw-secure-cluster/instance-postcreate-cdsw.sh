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

# install git
yum -y install git

# install dnsmasq
yum -y install dnsmasq
cat /etc/resolv.conf | grep nameserver > /etc/dnsmasq.resolv.conf
perl -pi -e "s|^.*?resolv-file.*?$|resolv-file=/etc/dnsmasq.resolv.conf|" /etc/dnsmasq.conf
systemctl start dnsmasq
systemctl enable dnsmasq

# Add DNS(dnsmasq on local)
perl -pi -e "s/nameserver.*$/nameserver $(hostname -i)/" /etc/resolv.conf
chattr +i /etc/resolv.conf 


# Change CDSW DNS settings
yum -y install epel-release
yum -y install jq

CDSW_DOMAIN="cdsw.$(hostname -i).xip.io"
CDSW_SERVICE_NAME=$(curl -s -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services |  jq -r '.items[] | select( .type == "CDSW") | .name')
curl -X PUT -H "Content-Type:application/json" -u ${CM_USERNAME}:${CM_PASSWORD} -d '{ "items": [ { "name": "cdsw.domain.config", "value": "'${CDSW_DOMAIN}'" }] }' http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/config
curl -X POST -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/commands/restart
sleep 10

# Waiting for CDSW is up
for i in `seq 60` : # 60*10sec -> 10min
do
    cdsw status
    if [ $? -eq 0 ]; then
        echo "CDSW is now up and ready."
        break
    fi
    echo "Waiting for CDSW is up.... 10 seconds."
    sleep 10
done

exit 0
