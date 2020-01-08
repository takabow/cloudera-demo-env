s #!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/instance-postcreate-cdsw-gpu.log 2>&1
date

# Check CDSW node identifier set by bootstrap-cdsw-init.sh
if [ ! -e /root/cdsw ]; then
echo "This is not a cdsw node."
exit 0
fi

# Settings for GPU
## Installing some tools
yum groupinstall -y "Development tools"
#curl -OL http://ftp.riken.jp/Linux/cern/centos/7/updates/x86_64/Packages/kernel-devel-3.10.0-514.16.1.el7.x86_64.rpm
curl -OL http://ftp.riken.jp/Linux/cern/centos/7/updates/x86_64/Packages/kernel-devel-3.10.0-693.5.2.el7.x86_64.rpm
#curl -OL http://ftp.riken.jp/Linux/cern/centos/7/updates/x86_64/Packages/kernel-devel-`uname -r`.rpm
#yum install -y kernel-devel-3.10.0-514.16.1.el7.x86_64.rpm
yum install -y kernel-devel-3.10.0-693.5.2.el7.x86_64.rpm

## Installing NVIDIA Driver
# OLD
#NVIDIA_DRIVER_VERSION="381.22"
#curl -OL http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run

# NEW
#NVIDIA K80 GPU
#https://www.nvidia.co.jp/Download/driverResults.aspx/155532/jp
#https://www.nvidia.com/Download/driverResults.aspx/155291/en-us

NVIDIA_DRIVER_VERSION="418.116.00"
curl -OL http://us.download.nvidia.com/tesla/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run
chmod 755 NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run
./NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run -asq

nvidia-smi

#https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/optimize_gpu.html
nvidia-persistenced
nvidia-smi --auto-boost-default=0
nvidia-smi -ac 2505,875


## GPU settings on CDSW
#NVIDIA_LIBRARY_PATH="/var/lib/nvidia-docker/volumes/nvidia_driver/${NVIDIA_DRIVER_VERSION}"
CDSW_SERVICE_NAME=$(curl -s -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services |  jq -r '.items[] | select( .type == "CDSW") | .name')
#curl -X PUT -H "Content-Type:application/json" -u ${CM_USERNAME}:${CM_PASSWORD} -d '{ "items": [ { "name": "cdsw.nvidia.lib.path.config", "value": "'${NVIDIA_LIBRARY_PATH}'" }] }' http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/config
curl -X PUT -H "Content-Type:application/json" -u ${CM_USERNAME}:${CM_PASSWORD} -d '{ "items": [ { "name": "cdsw.enable.gpu.config", "value": "true" }] }' http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/config

curl -X POST -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${CDSW_SERVICE_NAME}/commands/restart
#sleep 10
