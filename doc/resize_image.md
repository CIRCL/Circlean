Add empty space to the image
============================

* Add 2Gb

```
    > dd if=/dev/zero bs=1024k count=2048 >> 2016-03-18-raspbian-jessie-lite.img
```

Expand partition size
=====================

```
    > fdisk 2016-03-18-raspbian-jessie-lite.img

    Command (m for help): *p*
    Disk 2016-03-18-raspbian-jessie-lite.img: 3.3 GiB, 3508535296 bytes, 6852608 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x6f92008e

    Device                               Boot  Start     End Sectors  Size Id Type
    2016-03-18-raspbian-jessie-lite.img1        8192  131071  122880   60M  c W95 FAT32 (LBA)
    2016-03-18-raspbian-jessie-lite.img2      131072 2658303 2527232  1.2G 83 Linux

    Command (m for help): *d*
    Partition number (1,2, default 2): *2*

    Partition 2 has been deleted.

    Command (m for help): *n*
    Partition type
       p   primary (1 primary, 0 extended, 3 free)
       e   extended (container for logical partitions)
    Select (default p):

    Using default response p.
    Partition number (2-4, default 2):
    First sector (2048-6852607, default 2048): *131072*
    Last sector, +sectors or +size{K,M,G,T,P} (131072-6852607, default 6852607):

    Created a new partition 2 of type 'Linux' and of size 3.2 GiB.

    Command (m for help): *w*
    The partition table has been altered.
    Syncing disks.
```

Resize partition
================

* Chroot in the image

```
    sudo ./proper_chroot.sh
```

* Resize the partition (not from the chroot)

```
    > df | grep /mnt/arm

    /dev/loop0                3927752   1955672   1794172  53% /mnt/arm_rPi
    /dev/loop1                  57288     18960     38328  34% /mnt/arm_rPi/boot

    > sudo resize2fs /dev/loop0
```
