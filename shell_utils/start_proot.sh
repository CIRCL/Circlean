#!/bin/bash

# This script runs proot on a mounted image with the proper parameters.
# The root partition should be at /mnt/rpi-root /mnt/rpt-boot
# You should probably run something like basic_mount_image.sh first

set -e
set -x

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

sudo proot -q qemu-arm -S /mnt/rpi-root -b /mnt/rpi-boot:/boot /bin/bash
