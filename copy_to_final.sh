#!/bin/bash

CHROOT_PATH='/mnt/arm_rPi'

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# copy deb
#cp deb/*.deb ${CHROOT_PATH}/

# prepare fs archive
tar -cvpzf backup.tar.gz -C fs/ .
tar -xzf backup.tar.gz -C ${CHROOT_PATH}/
cp deb/led ${CHROOT_PATH}/usr/sbin/led

losetup -o $((122880 * 512)) /dev/loop0 NEW_FINAL_2013-02-09-wheezy-raspbian.img
resize2fs /dev/loop0
losetup -d /dev/loop0

#sudo dd bs=4M if=NEW_FINAL_2013-02-09-wheezy-raspbian.img of=/dev/sdd

# /!\ always try to mount the root partition on the SD, it is usually broken.
# if it is, use fdisk to remove the second partition and recreate it (you will
# not lose the data).
# See resize_img.md
