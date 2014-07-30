#!/bin/bash

# Notes:
# - To chroot in an existing SD card, unset IMAGE. Change the paths to the partitions if needed.
# - The offsets are thoses of 2013-02-09-wheezy-raspbian.img. It will change on an other image.
#   To get the offsets, use the "file" command.

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
ls /usr/bin/qemu*arm*
if [ -z $? ]; then
    echo "You need qemu user static binaries." 1>&2
    exit 1
fi
if [ -z "$1" ]; then
    echo "Please tell me what do to after mounting everything..."
    exit
fi
COMMAND=${1}

set -e
set -x

# If you use a partition...
#PARTITION_ROOTFS='/dev/mmcblk0p2'
#PARTITION_BOOT='/dev/mmcblk0p1'
PARTITION_ROOTFS='/dev/sdd2'
PARTITION_BOOT='/dev/sdd1'

# If you use the img
##### Debian
IMAGE='2014-06-20-wheezy-raspbian.img'
OFFSET_ROOTFS=$((122880 * 512))
OFFSET_BOOT=$((8192 * 512))
##### Arch
#IMAGE='archlinux-hf-2013-02-11.img'
#OFFSET_ROOTFS=$((186368 * 512))
#OFFSET_BOOT=$((2048 * 512))
############

CHROOT_PATH='/mnt/arm_rPi'

clean(){
    mv ${CHROOT_PATH}/etc/ld.so.preload_bkp ${CHROOT_PATH}/etc/ld.so.preload
    rm ${CHROOT_PATH}/etc/resolv.conf
    rm ${CHROOT_PATH}/usr/bin/qemu*arm*

    umount ${CHROOT_PATH}/dev/pts
    #umount ${CHROOT_PATH}/dev/shm
    umount ${CHROOT_PATH}/dev
    umount ${CHROOT_PATH}/run
    umount ${CHROOT_PATH}/proc
    umount ${CHROOT_PATH}/sys
    umount ${CHROOT_PATH}/tmp
    umount ${CHROOT_PATH}/boot
    umount ${CHROOT_PATH}

    rm -rf ${CHROOT_PATH}
}

trap clean EXIT TERM INT

# enforce the CPU in order to have the armv6 instructions set (and compile working packages...)
export QEMU_CPU=arm1176
#export QEMU_STRACE=1

mkdir -p ${CHROOT_PATH}

if [ ! -z ${IMAGE} ]; then
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

mount -o bind /run ${CHROOT_PATH}/run
mount -o bind /dev ${CHROOT_PATH}/dev
mount -t devpts pts ${CHROOT_PATH}/dev/pts
#mount -o bind /dev/shm ${CHROOT_PATH}/dev/shm
mount -t proc none ${CHROOT_PATH}/proc
mount -t sysfs none ${CHROOT_PATH}/sys
mount -o bind /tmp ${CHROOT_PATH}/tmp

cp -pf /etc/resolv.conf ${CHROOT_PATH}/etc

mv ${CHROOT_PATH}/etc/ld.so.preload ${CHROOT_PATH}/etc/ld.so.preload_bkp

${COMMAND} ${CHROOT_PATH}
