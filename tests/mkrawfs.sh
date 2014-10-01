#!/bin/bash
# Doc: http://wiki.osdev.org/Loopback_Device


set -e
set -x

FS_EXT='ext2 ext3 ext4'
FS_VFAT='vfat'
FS_NTFS='ntfs'

SIZE_MB='128'

# System
FS="${FS_EXT} ${FS_VFAT} ${FS_NTFS}"

IMAGE_DEST="testcase_dest.vfat"
dd if=/dev/zero of=${IMAGE_DEST} bs=516096c count=200
parted -s ${IMAGE_DEST} mklabel msdos
parted -s ${IMAGE_DEST} mkpart primary 8192s 201599s
lo=`losetup -f`
losetup -o$((8192 * 512)) ${lo} ${IMAGE_DEST}
mkfs.vfat ${lo}
losetup -d ${lo}

for f in $FS; do
    # Create files of 128Mb
    OUT_NAME_NORM="testcase."${f}
    dd if=/dev/zero of=${OUT_NAME_NORM} bs=516096c count=200
    parted -s ${OUT_NAME_NORM} mklabel msdos
    if [ $f = ${FS_VFAT} ]; then
        OUT_NAME_PART="testcase.part."${f}
        dd if=/dev/zero of=${OUT_NAME_PART} bs=516096c count=200
        parted -s ${OUT_NAME_PART} mklabel msdos
        parted -s ${OUT_NAME_PART} mkpart primary 8192s 122879s
        parted -s ${OUT_NAME_PART} mkpart primary 122880s 201599s

        lo=`losetup -f`
        losetup -o$((8192 * 512)) ${lo} ${OUT_NAME_PART}
        mkfs.${f} ${lo} 57344
        losetup -d ${lo}
        losetup -o$((122880 * 512)) ${lo} ${OUT_NAME_PART}
        mkfs.${f} ${lo} 39360
        losetup -d ${lo}

        parted -s ${OUT_NAME_NORM} mkpart primary 8192s 201599s
        losetup -o$((8192 * 512)) ${lo} ${OUT_NAME_NORM}
        mkfs.${f} ${lo}
        losetup -d ${lo}
    elif [ $f = ${FS_NTFS} ]; then
        parted -s ${OUT_NAME_NORM} mkpart primary 8192s 201599s
        lo=`losetup -f`
        losetup -o$((8192 * 512)) ${lo} ${OUT_NAME_NORM}
        mk${f} -f -I ${lo}
        losetup -d ${lo}
    else
        parted -s ${OUT_NAME_NORM} mkpart primary 8192s 201599s
        lo=`losetup -f`
        losetup -o$((8192 * 512)) ${lo} ${OUT_NAME_NORM}
        mkfs.${f} ${lo}
        losetup -d ${lo}
    fi
done

