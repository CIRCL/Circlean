#!/bin/bash

CHROOT_PATH='/mnt/arm_rPi'

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# copy deb
cp deb/*.deb ${CHROOT_PATH}/

# prepare fs archive
tar -cvpzf backup.tar.gz -C fs/ .
tar -xzfv backup.tar.gz -C ${CHROOT_PATH}/

sudo dd bs=4M if=FINAL_2013-02-09-wheezy-raspbian.img of=/dev/sdd

# /!\ always try to mount the root partition on the SD, it is usually brocken.
# if it is, use fdisk to remove the second partition and recreate it
# if you run rasp-config at least once, you will see the script running in case
# you have a screen connected.

