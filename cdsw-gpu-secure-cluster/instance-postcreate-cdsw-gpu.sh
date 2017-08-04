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

# Settings for GPU
## Installing some tools
yum groupinstall -y "Development tools"
yum install -y kernel-devel-`uname -r`

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
perl -pi -e "s/NVIDIA_GPU_ENABLE=.*/NVIDIA_GPU_ENABLE=true/" /etc/cdsw/config/cdsw.conf
perl -pi -e "s|NVIDIA_LIBRARY_PATH=.*|NVIDIA_LIBRARY_PATH=\"${NVIDIA_LIBRARY_PATH}\"|" /etc/cdsw/config/cdsw.conf
cdsw restart

# Waiting for CDSW is up after restart
for i in `seq 30` : # 30*10sec -> 5min
do
    cdsw status
    if [ $? -eq 0 ]; then
        echo "CDSW is no up and ready."
        break
    fi
    echo "Waiting for CDSW is up.... 10 seconds."
    sleep 10
done
