#!/bin/bash

# http://xecdesign.com/qemu-emulating-raspberry-pi-the-easy-way/

IMAGE='2014-01-07-wheezy-raspbian.img'
OFFSET_ROOTFS=$((122880 * 512))

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

set -e

./mount_image.sh ./copy_force_shell.sh

SETUP_DIR="setup"

clean(){
    mount -o loop,offset=${OFFSET_ROOTFS} ${IMAGE} ${SETUP_DIR}
    mv ${SETUP_DIR}/etc/ld.so.preload_bkp ${SETUP_DIR}/etc/ld.so.preload
    umount ${SETUP_DIR}
    rm -rf ${SETUP_DIR}
    ./mount_image.sh ./copy_to_final.sh
}

trap clean EXIT TERM INT

mkdir -p ${SETUP_DIR}

# make the CIRCLean image compatible with qemu
mount -o loop,offset=${OFFSET_ROOTFS} ${IMAGE} ${SETUP_DIR}
mv ${SETUP_DIR}/etc/ld.so.preload ${SETUP_DIR}/etc/ld.so.preload_bkp
umount ${SETUP_DIR}

./get_shell.exp ${IMAGE}


