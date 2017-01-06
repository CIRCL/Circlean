#!/bin/bash

IMAGE='2016-05-12_CIRCLean.img'
OFFSET=$((512 * 131072))

mkdir /mnt/rpi
mount -v -o offset=${OFFSET} -t ext4 ${IMAGE} /mnt/rpi
