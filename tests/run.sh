#!/bin/bash

# http://xecdesign.com/qemu-emulating-raspberry-pi-the-easy-way/

IMAGE='../old/2013-12-09_CIRCLean.img'
OFFSET_ROOTFS=$((122880 * 512))

IMAGE_VFAT_NORM="testcase.vfat"
OFFSET_VFAT_NORM=$((8192 * 512))

IMAGE_VFAT_PART="testcase.part.vfat"
OFFSET_VFAT_PART1=$((8192 * 512))
OFFSET_VFAT_PART2=$((122880 * 512))

IMAGE_DEST="testcase_dest.vfat"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

set -e
set -x

SETUP_DIR="setup"

clean(){
    mount -o loop,offset=${OFFSET_ROOTFS} ${IMAGE} ${SETUP_DIR}
    mv ${SETUP_DIR}/etc/ld.so.preload_bkp ${SETUP_DIR}/etc/ld.so.preload
    umount ${SETUP_DIR}
    rm -rf ${SETUP_DIR}
}

trap clean EXIT TERM INT

mkdir -p ${SETUP_DIR}

# make the CIRCLean image compatible with qemu
mount -o loop,offset=${OFFSET_ROOTFS} ${IMAGE} ${SETUP_DIR}
mv ${SETUP_DIR}/etc/ld.so.preload ${SETUP_DIR}/etc/ld.so.preload_bkp
umount ${SETUP_DIR}

# Prepare the test source key
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_VFAT_NORM} ${SETUP_DIR}
cp content_img_vfat_norm/* ${SETUP_DIR}
umount ${SETUP_DIR}
# Prepare the test source key (with partitions)
mount -o loop,offset=${OFFSET_VFAT_PART1} ${IMAGE_VFAT_PART} ${SETUP_DIR}
cp content_img_vfat_part1/* ${SETUP_DIR}
umount ${SETUP_DIR}
mount -o loop,offset=${OFFSET_VFAT_PART2} ${IMAGE_VFAT_PART} ${SETUP_DIR}
cp content_img_vfat_part2/* ${SETUP_DIR}
umount ${SETUP_DIR}


qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb \
    -watchdog i6300esb -watchdog-action poweroff \
    -serial stdio -append "root=/dev/sdc2 panic=1 rootfstype=ext4 rw" \
    -drive file=${IMAGE_VFAT_NORM},index=0,media=disk \
    -drive file=${IMAGE_DEST},index=1,media=disk \
    -vnc 0.0.0.0:1 -drive file=${IMAGE},index=2,media=disk



