#!/bin/bash

# http://pub.phyks.me/respawn/mypersonaldata/public/2014-05-20-11-08-01/

# To make debugging easier
echo "KittenGroomer: in tests/run.sh" 1>&2

if [ -z "$1" ]; then
    echo "Please tell me which partition type to test."
    echo "VFAT_NORM VFAT_PART NTPS_NORM EXT2 EXT3 EXT4"
    exit
fi
if [ -z "$2" ]; then
    echo "Please tell me which file type to test."
    echo "t_images1"
    exit
fi
TEST_PART_TYPE=${1}
TEST_SOURCE_TYPE=${2}

IMAGE='../raspbian-wheezy.img'
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
if [ ${TEST_PART_TYPE} = "VFAT_NORM" ]; then
    mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_VFAT_NORM} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
fi

# Prepare the test source key (with partitions)
if [ ${TEST_PART_TYPE} = "VFAT_PART" ]; then
    mount -o loop,offset=${OFFSET_VFAT_PART1} ${IMAGE_VFAT_PART} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
    mount -o loop,offset=${OFFSET_VFAT_PART2} ${IMAGE_VFAT_PART} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
fi

# Prepare the test source key (NTFS)
if [ ${TEST_PART_TYPE} = "NTFS_NORM" ]; then
    mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_NTFS_NORM} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
fi

# Prepare the test source key (EXT2)
if [ ${TEST_PART_TYPE} = "EXT2" ]; then
    mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_EXT2} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
fi

# Prepare the test source key (EXT3)
if [ ${TEST_PART_TYPE} = "EXT4" ]; then
    mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_EXT3} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
fi

# Prepare the test source key (EXT4)
if [ ${TEST_PART_TYPE} = "EXT4" ]; then
    mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_EXT4} ${SETUP_DIR}
    rm -rf ${SETUP_DIR}/*
    cp -rf testFiles/${TEST_SOURCE_TYPE}/* ${SETUP_DIR}
    umount ${SETUP_DIR}
fi

# Prepare the test destination key
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_DEST} ${SETUP_DIR}
rm -rf ${SETUP_DIR}/*
umount ${SETUP_DIR}


# To make debugging easier
echo "KittenGroomer: about to enter tests/run.exp" 1>&2

chmod a-w ${IMAGE}


if [ ${TEST_PART_TYPE} = "VFAT_NORM" ]; then
    ./run.exp ${IMAGE} ${IMAGE_VFAT_NORM} ${IMAGE_DEST}
    sleep 10
fi

if [ ${TEST_PART_TYPE} = "VFAT_PART" ]; then
    ./run.exp ${IMAGE} ${IMAGE_VFAT_PART} ${IMAGE_DEST}
    sleep 10
fi

if [ ${TEST_PART_TYPE} = "NTFS_NORM" ]; then
    ./run.exp ${IMAGE} ${IMAGE_NTFS_NORM} ${IMAGE_DEST}
    sleep 10
fi

# EXT* not supported due to permission issues
if [ ${TEST_PART_TYPE} = "EXT2" ]; then
    ./run.exp ${IMAGE} ${IMAGE_EXT2} ${IMAGE_DEST}
    sleep 10
fi
if [ ${TEST_PART_TYPE} = "EXT3" ]; then
    ./run.exp ${IMAGE} ${IMAGE_EXT3} ${IMAGE_DEST}
    sleep 10
fi
if [ ${TEST_PART_TYPE} = "NTFS_EXT4" ]; then
    ./run.exp ${IMAGE} ${IMAGE_EXT4} ${IMAGE_DEST}
    sleep 10
fi

chmod +w ${IMAGE}

# To make debugging easier
echo "KittenGroomer: done with tests/run.sh" 1>&2
