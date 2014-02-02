#!/bin/bash
# Doc: http://wiki.osdev.org/Loopback_Device


set -e
set -x

# User
#FS_EXT='ext2 ext3 ext4'
FS_VFAT='vfat'
#FS_NTFS='ntfs'
SIZE_MB='128'

# System
FS="${FS_EXT} ${FS_VFAT} ${FS_NTFS}"


for f in $FS; do
    # Create files of 128Mb
    OUT_NAME_NORM="testcase."${f}
    OUT_NAME_PART="testcase.part."${f}
    dd if=/dev/zero of=${OUT_NAME_NORM} bs=516096c count=200
    dd if=/dev/zero of=${OUT_NAME_PART} bs=516096c count=200
    parted -s ${OUT_NAME_NORM} mklabel msdos
    parted -s ${OUT_NAME_PART} mklabel msdos
    if [ $f = ${FS_VFAT} ]; then
        parted -s ${OUT_NAME_PART} mkpart primary 8192s 122879s
        parted -s ${OUT_NAME_PART} mkpart primary 122880s 201599s
        parted -s ${OUT_NAME_NORM} mkpart primary 8192s 201599s
        losetup -o$((8192 * 512)) /dev/loop0 ${OUT_NAME_PART}
        losetup -o$((122880 * 512)) /dev/loop1 ${OUT_NAME_PART}
        losetup -o$((8192 * 512)) /dev/loop2 ${OUT_NAME_NORM}
        mkfs.${f} /dev/loop0 57344
        mkfs.${f} /dev/loop1 39360
        mkfs.${f} /dev/loop2
        losetup -d /dev/loop0
        losetup -d /dev/loop1
        losetup -d /dev/loop2
    elif [ $f = ${FS_NTFS} ]; then
        mk${f} -f -F ${OUT_NAME}
    else
        mkfs.${f} -F ${OUT_NAME}
    fi
done

