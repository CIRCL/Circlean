#!/bin/bash

# This script will mount a given image or sd card in loop mode.
# Make sure to change the path and offsets for the image you use. You can get
# the correct offsets using `file $PATH_TO_IMAGE` or fdisk.
# If you want to mount an SD card, unset $IMAGE.

# To make debugging easier
echo "KittenGroomer: in mount_image.sh" 1>&2

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
COMMAND_OPT=${2}

set -e
set -x

# If you use a partition...
PARTITION_ROOTFS='/dev/mmcblk0p2'
PARTITION_BOOT='/dev/mmcblk0p1'
#PARTITION_ROOTFS='/dev/sdd2'
#PARTITION_BOOT='/dev/sdd1'

# If you use the img...
# Double check the path and offsets as noted above!
##### Debian
IMAGE='2016-05-09_CIRCLean.img'
OFFSET_BOOT=$((8192 * 512))
OFFSET_ROOTFS=$((131072 * 512))

CHROOT_PATH='/mnt/arm_rPi'

clean(){
    mv ${CHROOT_PATH}/etc/ld.so.preload_backup ${CHROOT_PATH}/etc/ld.so.preload
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
    echo 'You need a SD card or an image'
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

mv ${CHROOT_PATH}/etc/ld.so.preload ${CHROOT_PATH}/etc/ld.so.preload_backup

# To make debugging easier
echo "KittenGroomer: Image mounted, executing command from mount_image.sh" 1>&2

${COMMAND} ${CHROOT_PATH} ${COMMAND_OPT}
