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
