#!/bin/bash

# http://xecdesign.com/qemu-emulating-raspberry-pi-the-easy-way/

IMAGE='../2015-02-16-raspbian-wheezy.img'
OFFSET_ROOTFS=$((122880 * 512))

IMAGE_VFAT_NORM="testcase.vfat"
IMAGE_NTFS_NORM="testcase.ntfs"
IMAGE_EXT2="testcase.ext2"
IMAGE_EXT3="testcase.ext3"
IMAGE_EXT4="testcase.ext4"
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
cp -rf content_img_vfat_norm/* ${SETUP_DIR}
umount ${SETUP_DIR}
# Prepare the test source key (with partitions)
mount -o loop,offset=${OFFSET_VFAT_PART1} ${IMAGE_VFAT_PART} ${SETUP_DIR}
cp -rf content_img_vfat_part1/* ${SETUP_DIR}
umount ${SETUP_DIR}
mount -o loop,offset=${OFFSET_VFAT_PART2} ${IMAGE_VFAT_PART} ${SETUP_DIR}
cp -rf content_img_vfat_part2/* ${SETUP_DIR}
umount ${SETUP_DIR}
# Prepare the test source key (NTFS)
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_NTFS_NORM} ${SETUP_DIR}
cp -rf content_img_vfat_norm/* ${SETUP_DIR}
umount ${SETUP_DIR}
# Prepare the test source key (EXT2)
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_EXT2} ${SETUP_DIR}
cp -rf content_img_vfat_norm/* ${SETUP_DIR}
umount ${SETUP_DIR}
# Prepare the test source key (EXT3)
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_EXT3} ${SETUP_DIR}
cp -rf content_img_vfat_norm/* ${SETUP_DIR}
umount ${SETUP_DIR}
# Prepare the test source key (EXT4)
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_EXT4} ${SETUP_DIR}
cp -rf content_img_vfat_norm/* ${SETUP_DIR}
umount ${SETUP_DIR}

chmod -w ${IMAGE}
./run.exp ${IMAGE} ${IMAGE_VFAT_NORM} ${IMAGE_DEST}
#sleep 10
#./run.exp ${IMAGE} ${IMAGE_VFAT_PART} ${IMAGE_DEST}
#sleep 10
#./run.exp ${IMAGE} ${IMAGE_NTFS_NORM} ${IMAGE_DEST}

# EXT* not supported due to permission issues
#sleep 10
#./run.exp ${IMAGE} ${IMAGE_EXT2} ${IMAGE_DEST}
#sleep 10
#./run.exp ${IMAGE} ${IMAGE_EXT3} ${IMAGE_DEST}
#sleep 10
#./run.exp ${IMAGE} ${IMAGE_EXT4} ${IMAGE_DEST}


#./run.exp ${IMAGE} ${IMAGE_VFAT_PART} ${IMAGE_DEST}
chmod +w ${IMAGE}

