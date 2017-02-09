#!/bin/bash

# This script will mount a given image in loop mode.
# Make sure to change the path and offsets for the image you use. You can get
# the correct offsets using `file $PATH_TO_IMAGE` or fdisk.

# To make debugging easier
echo "KittenGroomer: in mount_image.sh" 1>&2

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

set -e
set -x

# Double check the path and offsets as noted above!
# Path to the image
IMAGE='2017-02-02_CIRCLean.img'
# Start sector of boot (first) partition
BOOT_START=8192
# Start sector of root (second) partition
ROOT_START=137216
# Locations you'd like the partitions mounted
BOOT_PATH='/mnt/rpi-boot'
ROOTFS_PATH='/mnt/rpi-root'

# Calculate offsets for each partition
offset_boot=$((${BOOT_START} * 512))
offset_rootfs=$((${ROOT_START} * 512))
# TODO: add logic for creating directories if they aren't already there
mkdir -p ${BOOT_PATH}
mkdir -p ${ROOTFS_PATH}
# Mount each partition in loop mode
mount -o loop,offset=${offset_boot} ${IMAGE} ${BOOT_PATH}
mount -o loop,offset=${offset_rootfs} ${IMAGE} ${ROOTFS_PATH}

echo "Image mounted" 1>&2
