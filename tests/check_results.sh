#!/bin/bash

# To make debugging easier
echo "KittenGroomer: in tests/check_results.sh" 1>&2

OFFSET_VFAT_NORM=$((8192 * 512))
IMAGE_DEST="testcase_dest.vfat"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ -z "$1" ]; then
    echo "Please tell me which file type to test."
    echo "t_images1"
    exit
fi
TEST_SOURCE_TYPE=${2}

set -e
set -x

RESULTS_DIR="results"

# To make debugging easier
echo "Removing results from previous run." 1>&2
rm -rf actualResults/*

clean(){
    umount ${RESULTS_DIR}
    rm -rf ${RESULTS_DIR}
}

trap clean EXIT TERM INT

mkdir -p ${RESULTS_DIR}

# Get the run results
mount -o loop,offset=${OFFSET_VFAT_NORM} ${IMAGE_DEST} ${RESULTS_DIR}
cp -rf ${RESULTS_DIR}/* actualResults
umount ${RESULTS_DIR}



# To make debugging easier
echo "KittenGroomer: done with tests/check_results.sh" 1>&2
