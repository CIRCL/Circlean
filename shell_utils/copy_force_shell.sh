#!/bin/bash

set -e
set -x

if [ -z "$1" ]; then
    echo "Path to the mounted image needed."
    exit
fi

CHROOT_PATH=${1}

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# prepare fs archive
tar -cvpzf backup.tar.gz -C fs_shell/ .
tar -xzf backup.tar.gz -C ${CHROOT_PATH}/
