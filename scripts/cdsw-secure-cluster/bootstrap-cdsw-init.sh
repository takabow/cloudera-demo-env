#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/bootstrap-cdsw-init.log 2>&1
date

# Worker node identifier
touch /root/cdsw

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
