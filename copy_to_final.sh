#!/bin/bash

set -e
set -x

if [ -z "$1" ]; then
    echo "Path to the mounted image needed."
    exit
fi

CHROOT_PATH=${1}

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# copy deb
#cp deb/*.deb ${CHROOT_PATH}/

# prepare fs archive
tar -cvpzf backup.tar.gz -C fs/ .
tar -xzf backup.tar.gz -C ${CHROOT_PATH}/
chown root:root ${CHROOT_PATH}/etc/sudoers
if [ -f deb/led ]; then
    cp deb/led ${CHROOT_PATH}/usr/sbin/led
fi
cp -rf midi ${CHROOT_PATH}/opt/

# needed just once, make sure the size of the partition is correct
#losetup -o $((122880 * 512)) /dev/loop0 FINAL_2013-09-10-wheezy-raspbian.img
#e2fsck -f /dev/loop0
#resize2fs /dev/loop0
#losetup -d /dev/loop0

#sudo dd bs=4M if=FINAL_2013-09-10-wheezy-raspbian.img of=/dev/sdd

# /!\ always try to mount the root partition on the SD, it is usually broken.
# if it is, use fdisk to remove the second partition and recreate it (you will
# not lose the data).
# See resize_img.md


# It is also a good idea to run raspi-config once and enable the console login (allow debugging)
