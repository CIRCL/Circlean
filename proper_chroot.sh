#!/bin/bash

set -e
set -x

PARTITION='/dev/mmcblk0p2'
CHROOT_PATH='/mnt/arm_rPi'

clean(){
    mv ${CHROOT_PATH}/etc/ld.so.preload_bkp ${CHROOT_PATH}/etc/ld.so.preload
    rm ${CHROOT_PATH}/etc/resolv.conf
    rm ${CHROOT_PATH}/usr/bin/qemu-static-arm*

    umount ${CHROOT_PATH}/dev/pts
    umount ${CHROOT_PATH}/dev/shm
    umount ${CHROOT_PATH}/dev
    umount ${CHROOT_PATH}/proc
    umount ${CHROOT_PATH}/sys
    umount ${CHROOT_PATH}/tmp
    umount ${CHROOT_PATH}

    rm -rf ${CHROOT_PATH}
}

trap clean EXIT TERM INT

mkdir -p ${CHROOT_PATH}
mount ${PARTITION} ${CHROOT_PATH}

cp /usr/bin/qemu-static-arm* ${CHROOT_PATH}/usr/bin/

mount -o bind /dev ${CHROOT_PATH}/dev
mount -o bind /dev/pts ${CHROOT_PATH}/dev/pts
mount -o bind /dev/shm ${CHROOT_PATH}/dev/shm
mount -o bind /proc ${CHROOT_PATH}/proc
mount -o bind /sys ${CHROOT_PATH}/sys
mount -o bind /tmp ${CHROOT_PATH}/tmp

cp -pf /etc/resolv.conf ${CHROOT_PATH}/etc
mv ${CHROOT_PATH}/etc/ld.so.preload ${CHROOT_PATH}/etc/ld.so.preload_bkp

chroot ${CHROOT_PATH}
