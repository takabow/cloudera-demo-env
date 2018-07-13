#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/instance-postcreate-cdsw-gpu.log 2>&1
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
#curl -X POST -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/commands/restart
#sleep 10

# Settings for GPU
## Installing some tools
yum groupinstall -y "Development tools"
curl -OL http://ftp.riken.jp/Linux/cern/centos/7/updates/x86_64/Packages/kernel-devel-3.10.0-514.16.1.el7.x86_64.rpm
yum install -y kernel-devel-3.10.0-514.16.1.el7.x86_64.rpm

## Installing NVIDIA Driver
NVIDIA_DRIVER_VERSION="381.22"
curl -OL http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run
chmod 755 NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run
./NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run -asq
/usr/bin/nvidia-smi

## Installing nvidia-docker
curl -OL https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker-1.0.1-1.x86_64.rpm
yum install -y nvidia-docker-1.0.1-1.x86_64.rpm
systemctl start nvidia-docker
systemctl enable nvidia-docker
systemctl status nvidia-docker

nvidia-docker run --rm nvidia/cuda:8.0 nvidia-smi

ls  /var/lib/nvidia-docker/volumes/nvidia_driver/
ls /var/lib/nvidia-docker/volumes/nvidia_driver/${NVIDIA_DRIVER_VERSION}/

## GPU settings on CDSW
NVIDIA_LIBRARY_PATH="/var/lib/nvidia-docker/volumes/nvidia_driver/${NVIDIA_DRIVER_VERSION}"
CDSW_SERVICE_NAME=$(curl -s -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services |  jq -r '.items[] | select( .type == "CDSW") | .name')
curl -X PUT -H "Content-Type:application/json" -u ${CM_USERNAME}:${CM_PASSWORD} -d '{ "items": [ { "name": "cdsw.nvidia.lib.path.config", "value": "'${NVIDIA_LIBRARY_PATH}'" }] }' http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/config
curl -X PUT -H "Content-Type:application/json" -u ${CM_USERNAME}:${CM_PASSWORD} -d '{ "items": [ { "name": "cdsw.enable.gpu.config", "value": "true" }] }' http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/config

curl -X POST -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/commands/restart
sleep 10

# Waiting for CDSW is up after restart
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
