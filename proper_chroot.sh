#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
ls /usr/bin/qemu*arm* > /dev/null 2>&1
if [ ! -e ${?} ]; then
    echo "You need qemu user static binaries." 1>&2
    exit 1
fi

set -e
set -x

# If you use a partition...
PARTITION_ROOTFS='/dev/mmcblk0p2'
PARTITION_BOOT='/dev/mmcblk0p1'
# If you use the img
IMAGE='2013-02-09-wheezy-raspbian.img'
OFFSET_ROOTFS=$((122880 * 512))
OFFSET_BOOT=$((8192 * 512))

CHROOT_PATH='/mnt/arm_rPi'

clean(){
    mv ${CHROOT_PATH}/etc/ld.so.preload_bkp ${CHROOT_PATH}/etc/ld.so.preload
    rm ${CHROOT_PATH}/etc/resolv.conf
    rm ${CHROOT_PATH}/usr/bin/qemu*arm*

    umount ${CHROOT_PATH}/dev/pts
    umount ${CHROOT_PATH}/dev/shm
    umount ${CHROOT_PATH}/dev
    umount ${CHROOT_PATH}/proc
    umount ${CHROOT_PATH}/sys
    umount ${CHROOT_PATH}/tmp
    umount ${CHROOT_PATH}/boot
    umount ${CHROOT_PATH}

    rm -rf ${CHROOT_PATH}
}

trap clean EXIT TERM INT

mkdir -p ${CHROOT_PATH}

if [ -a ${IMAGE} ]; then
    mount -o loop,offset=${OFFSET_ROOTFS} ${IMAGE} ${CHROOT_PATH}
    mount -o loop,offset=${OFFSET_BOOT} ${IMAGE} ${CHROOT_PATH}/boot
elif [ -a ${PARTITION_ROOTFS} ]; then
    mount ${PARTITION_ROOTFS} ${CHROOT_PATH}
    mount ${PARTITION_BOOT} ${CHROOT_PATH}/boot
else
    print 'You need a SD card or an image'
    exit
fi

cp /usr/bin/qemu*arm* ${CHROOT_PATH}/usr/bin/

mount -o bind /dev ${CHROOT_PATH}/dev
mount -o bind /dev/pts ${CHROOT_PATH}/dev/pts
mount -o bind /dev/shm ${CHROOT_PATH}/dev/shm
mount -o bind /proc ${CHROOT_PATH}/proc
mount -o bind /sys ${CHROOT_PATH}/sys
mount -o bind /tmp ${CHROOT_PATH}/tmp

cp -pf /etc/resolv.conf ${CHROOT_PATH}/etc

mv ${CHROOT_PATH}/etc/ld.so.preload ${CHROOT_PATH}/etc/ld.so.preload_bkp

chroot ${CHROOT_PATH}
